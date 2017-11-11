require_relative 'base_service'

class Chef
  class Resource
    class ProxysqlService < BaseService
      provides(:proxysql_service)

      # ProxySQL
      attribute(
        :version,
        kind_of: String,
        default: lazy { node['proxysql']['version'] }
      )
      attribute(:bin, kind_of: String, default: '/usr/bin/proxysql')
      attribute(:admin_socket, kind_of: [String, NilClass], default: nil)
      attribute(
        :flags,
        kind_of: Hash,
        default: lazy { node['proxysql']['service']['flags'] }
      )

      # Config
      attribute(
        :admin_variables,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['admin_variables'] }
      )
      attribute(
        :mysql_variables,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['mysql_variables'] }
      )
      attribute(
        :mysql_servers,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['mysql_servers'] }
      )
      attribute(
        :mysql_users,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['mysql_users'] }
      )
      attribute(
        :mysql_query_rules,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['mysql_query_rules'] }
      )
      attribute(
        :schedulers,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['schedulers'] }
      )
      attribute(
        :mysql_replication_hostgroups,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['mysql_replication_hostgroups'] }
      )

      # Service
      attribute(:service_name, kind_of: String, default: 'proxysql')
      attribute(:service_unit_after, kind_of: Array, default: %w[network.target])
      attribute(:service_install_wanted_by, kind_of: Array, default: %w[multi-user.target])
      attribute(:service_restart, kind_of: String, default: 'on-failure')
      attribute(:service_restart_sec, kind_of: Integer, default: 2)
    end
  end

  class Provider
    # rubocop:disable Metrics/ClassLength
    class ProxysqlService < BaseService
      provides(:proxysql_service)

      def action_delete
        service constructed_service_name do
          action %i[stop disable]
        end
        file config_file do
          action :delete
        end
        systemd_service_directory(action: :delete)
        file systemd_unit_path do
          action :delete
        end
      end

      protected

      def deriver_install
        install_proxysql
        create_directories(service_data_dir)
        install_config
        systemd_service_directory
        install_systemd_service

        service constructed_service_name do
          supports(
            status: true,
            restart: true
          )
          action %i[enable start]
        end
      end

      private

      def constructed_service_name
        [
          new_resource.service_name,
          new_resource.name
        ].join('-')
      end

      def config_file
        ::File.join(
          [
            new_resource.config_dir,
            "#{constructed_service_name}.cnf"
          ]
        )
      end

      def service_data_dir
        ::File.join([new_resource.data_dir, constructed_service_name])
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/PerceivedComplexity
      # rubocop:disable Style/GuardClause
      def validate!
        super
        if admin_mysql_ifaces
          # Check for .sock or IP:PORT
          unless admin_mysql_ifaces =~ /\.sock|\:\d+/
            raise "Provide admin_variables['mysql_ifaces'] in a form of "\
              "'127.0.0.1:6032' or '/var/lib/mysql/mysql.sock'"
          end
        else
          raise "Provide admin_variables['mysql_ifaces'] attribute"
        end
        if admin_credentials
          if admin_credentials.split(':').size != 2
            raise "Provide admin_variables['admin_credentials'] in a "\
              "form of 'admin:admin'"
          end
        else
          raise "Provide admin_variables['admin_credentials'] attribute"
        end

        output = Mixlib::ShellOut.new('which mysql').run_command
        unless output.status.success?
          raise 'Install MySQL client not found for loading '\
            'config to RUNTIME'
        end
      end

      def admin_variables
        new_resource.admin_variables
      end

      def admin_credentials
        admin_variables[:admin_credentials] || admin_variables['admin_credentials']
      end

      def admin_mysql_ifaces
        admin_variables[:mysql_ifaces] || admin_variables['mysql_ifaces']
      end

      def mysql_cmd
        connection = if admin_mysql_ifaces =~ /\.sock/
                       "--socket #{admin_mysql_ifaces}"
                     else
                       host, port = admin_mysql_ifaces.split(':')
                       "--host #{host} --port #{port}"
                     end
        user, pass = admin_credentials.split(':')
        "mysql --user=#{user} --password=#{pass} #{connection}"
      end

      def config_variables
        {
          data_dir: service_data_dir,
          admin_variables: admin_variables,
          mysql_variables: new_resource.mysql_variables,
          mysql_servers: make_config(new_resource.mysql_servers),
          mysql_users: make_config(new_resource.mysql_users),
          mysql_query_rules: make_config(new_resource.mysql_query_rules),
          schedulers: make_config(new_resource.schedulers),
          mysql_replication_hostgroups: make_config(new_resource.mysql_replication_hostgroups)
        }
      end

      def proxysql_statements
        [
          'LOAD MYSQL USERS FROM CONFIG',
          'LOAD MYSQL USERS TO RUNTIME',

          'LOAD MYSQL SERVERS FROM CONFIG',
          'LOAD MYSQL SERVERS TO RUNTIME',

          'LOAD MYSQL QUERY RULES FROM CONFIG',
          'LOAD MYSQL QUERY RULES TO RUNTIME',

          'LOAD MYSQL VARIABLES FROM CONFIG',
          'LOAD MYSQL VARIABLES TO RUNTIME',

          'LOAD ADMIN VARIABLES FROM DISK',
          'LOAD ADMIN VARIABLES TO RUNTIME'
        ]
      end

      def install_config
        statements = proxysql_statements.map { |statement| "#{statement};" }

        cmd = %(echo "#{statements.join(' ')}" | #{mysql_cmd})
        unit_path = systemd_unit_path

        execute 'load-config' do
          command cmd
          action :nothing
          only_if { ::File.exist?(unit_path) }
        end

        variables = config_variables
        template config_file do
          source 'proxysql.cnf.erb'
          variables variables
          owner new_resource.user
          group new_resource.group
          mode '0640'
          notifies :run, 'execute[load-config]', :immediately
          helpers(ProxysqlHelpers)
          cookbook 'proxysql'
        end
      end

      def service_args
        flags = new_resource.flags
                            .select { |_, on| on }
                            .map { |k, _| "--#{k}" }

        config = [
          flags,
          '--foreground',
          "--config #{config_file}",
          "--data_dir #{service_data_dir}"
        ]
        if new_resource.admin_socket
          config << "--admin-socket #{new_resource.admin_socket}"
        end
        config.flatten.join(' ')
      end

      def systemd_unit_path
        "/etc/systemd/system/#{constructed_service_name}.service"
      end

      def systemd_service_directory(action: :create)
        directory "#{systemd_unit_path}.d" do
          owner 'root'
          group 'root'
          mode '0750'
          action action
        end
      end

      def install_systemd_service
        execute 'systemctl-daemon-reload' do
          command '/bin/systemctl daemon-reload'
          action :nothing
        end

        variables = {
          unit_after: Array(new_resource.service_unit_after).join(' '),
          service_exec_start: "#{new_resource.bin} #{service_args}",
          service_restart: new_resource.service_restart,
          service_restart_sec: new_resource.service_restart_sec,
          service_user: new_resource.user,
          service_group: new_resource.group,
          install_wanted_by: Array(new_resource.service_install_wanted_by).join(' ')
        }

        template systemd_unit_path do
          source 'proxysql.service.erb'
          variables variables
          owner 'root'
          group 'root'
          mode '0644'
          notifies :run, 'execute[systemctl-daemon-reload]', :immediately
          helpers(ProxysqlHelpers)
          cookbook 'proxysql'
        end
      end

      def make_config(obj)
        hash_type = [Hash, Chef::Node::ImmutableMash]
        unless hash_type.include?(obj.class)
          raise "Provided #{obj} must be Chef::Node::ImmutableMash"\
            'or Array'
        end
        values = obj.values
        return [] if values.empty?

        array_type = [Array, Chef::Node::ImmutableArray]
        # Validating that each provided value is Array
        obj.each do |k, val|
          next if array_type.include?(val.class)
          raise "Provided key #{k} value #{val.class} must be of type"\
            'Chef::Node::ImmutableArray or Array'
        end
        values.reduce(&:concat).compact.uniq
      end

      def install_proxysql
        package 'proxysql' do
          version new_resource.version
        end

        # Remove package defaults
        %w[
          /etc/proxysql.cnf
          /etc/proxysql-admin.cnf
          /etc/init.d/proxysql
        ].each do |f|
          file f do
            action :delete
          end
        end
      end
    end
  end
end
