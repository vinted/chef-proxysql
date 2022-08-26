require_relative 'base_service'

class Chef
  class Resource
    class ProxysqlService < ProxysqlBaseService
      provides(:proxysql_service)

      # ProxySQL
      attribute(
        :version,
        kind_of: String,
        default: lazy { node['proxysql']['version'] }
      )
      # Package release
      # 1.1.xenial OR 1.1.el7 OR 1.1.el6
      attribute(
        :package_release,
        kind_of: String,
        default: lazy { node['proxysql']['package_release'] }
      )
      attribute(
        :lock_version,
        kind_of: [TrueClass, FalseClass],
        default: lazy { node['proxysql']['lock_version'] }
      )
      attribute(
        :pre_statements,
        kind_of: Array,
        default: lazy { node['proxysql']['pre_statements'] }
      )
      attribute(
        :post_statements,
        kind_of: Array,
        default: lazy { node['proxysql']['post_statements'] }
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
      attribute(
        :proxysql_servers,
        kind_of: Hash,
        default: lazy { node['proxysql']['config']['proxysql_servers'] }
      )

      # Service
      attribute(:service_name, kind_of: String, default: 'proxysql')
      attribute(:service_unit_after, kind_of: Array, default: %w[network.target])
      attribute(:service_limit_core, kind_of: Integer, default: 1_073_741_824)
      attribute(:service_limit_nofile, kind_of: Integer, default: 102_400)
      attribute(:service_timeout_sec, kind_of: Integer, default: 5)
      attribute(:service_restart, kind_of: String, default: 'on-failure')
    end
  end

  class Provider
    # rubocop:disable Metrics/ClassLength
    class ProxysqlService < ProxysqlBaseService
      provides(:proxysql_service)

      def action_delete
        service new_resource.service_name do
          action %i[stop disable]
        end
        file config_file do
          action :delete
        end
      end

      protected

      def deriver_install
        install_proxysql
        create_directories(service_data_dir)
        install_config
        install_service

        service new_resource.service_name do
          supports(
            status: true,
            restart: true
          )
          action %i[enable start]
        end
      end

      private

      def config_file
        ::File.join(
          [
            new_resource.config_dir,
            "#{new_resource.service_name}.cnf"
          ]
        )
      end

      def service_data_dir
        ::File.join([new_resource.data_dir, new_resource.service_name])
      end

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Style/GuardClause
      def validate!
        super
        if admin_mysql_ifaces
          # Check for .sock or IP:PORT
          unless admin_mysql_ifaces =~ /\.sock|:\d+/
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
      # rubocop:enable Style/GuardClause
      # rubocop:enable Metrics/AbcSize

      def admin_variables
        new_resource.admin_variables
      end

      def admin_credentials
        (admin_variables[:admin_credentials] || admin_variables['admin_credentials'])
          .split(';')
          .first
      end

      def admin_mysql_ifaces
        admin_variables[:mysql_ifaces] || admin_variables['mysql_ifaces']
      end

      def mysql_cmd
        admin_ifaces = admin_mysql_ifaces.split(';').map(&:strip)
        socket_iface = admin_ifaces.select { |i| i =~ /\.sock/ }.first

        connection = if socket_iface
                       "--socket #{socket_iface}"
                     else
                       host, port = admin_ifaces.first.split(':')
                       "--host #{host} --port #{port}"
                     end
        user, pass = admin_credentials.split(':')
        %(mysql --user="#{user}" --password="#{pass}" #{connection})
      end

      # rubocop:disable Metrics/AbcSize
      def config_variables
        {
          data_dir: service_data_dir,
          admin_variables: admin_variables,
          mysql_variables: new_resource.mysql_variables,
          schedulers: make_config(new_resource.schedulers),
          mysql_users: make_config(new_resource.mysql_users),
          mysql_servers: make_config(new_resource.mysql_servers),
          mysql_query_rules: make_config(new_resource.mysql_query_rules),
          mysql_replication_hostgroups: make_config(new_resource.mysql_replication_hostgroups),
          proxysql_servers: make_config(new_resource.proxysql_servers)
        }
      end
      # rubocop:enable Metrics/AbcSize

      # rubocop:disable Metrics/AbcSize
      def install_config
        pre_st = new_resource.pre_statements.map { |st| "#{st};" }
        post_st = new_resource.post_statements.map { |st| "#{st};" }
        pre_cmd = %(echo "#{pre_st.join(' ')}" | #{mysql_cmd})
        post_cmd = %(echo "#{post_st.join(' ')}" | #{mysql_cmd})
        variables = config_variables

        execute 'load-config' do
          command "#{pre_cmd} && #{post_cmd}"
          action :nothing
          only_if "systemctl is-active #{new_resource.service_name}"
        end

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
      # rubocop:enable Metrics/AbcSize

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
        config << "--admin-socket #{new_resource.admin_socket}" if new_resource.admin_socket
        config.flatten.join(' ')
      end

      # rubocop:disable Metrics/AbcSize
      def install_service
        exec_start = "#{new_resource.bin} #{service_args}"
        systemd_service new_resource.service_name do
          unit do
            description 'Chef managed ProxySQL service'
            after Array(new_resource.service_unit_after).join(' ')
          end

          install do
            wanted_by 'multi-user.target'
          end

          service do
            type 'simple'
            exec_start exec_start
            restart new_resource.service_restart
            timeout_sec new_resource.service_timeout_sec
            user new_resource.user
            group new_resource.group
            limit_core new_resource.service_limit_core
            limit_nofile new_resource.service_limit_nofile
          end
        end
      end
      # rubocop:enable Metrics/AbcSize

      def make_config(obj)
        hash_type = [Hash, Chef::Node::ImmutableMash]
        unless hash_type.include?(obj.class)
          raise "Provided #{obj} must be Chef::Node::ImmutableMash"\
            'or Array'
        end
        values = obj.to_h.values
        return [] if values.empty?

        array_type = [Array, Chef::Node::ImmutableArray]
        # Validating that each provided value is Array
        obj.each do |k, val|
          next if array_type.include?(val.class)

          raise "Provided key #{k} value #{val.class} must be of type"\
            'Chef::Node::ImmutableArray or Array'
        end
        values.reduce(&:concat).compact
      end

      def package_version
        [new_resource.version, new_resource.package_release].join('-')
      end

      def install_proxysql
        v = package_version
        package 'proxysql' do
          flush_cache [:before]
          version v if new_resource.lock_version
        end

        service 'proxysql' do
          action %i[stop disable]
          only_if { ::File.exist?('/lib/systemd/system/proxysql.service') }
        end

        # Remove package defaults
        %w[
          /etc/proxysql.cnf
          /etc/proxysql-admin.cnf
          /etc/init.d/proxysql
          /lib/systemd/system/proxysql.service
        ].each do |f|
          file f do
            action :delete
          end
        end
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
