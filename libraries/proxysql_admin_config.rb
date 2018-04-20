require_relative 'base_service'

class Chef
  class Resource
    class ProxysqlAdminConfig < ProxysqlBaseService
      provides(:proxysql_admin_config)

      # ProxySQL admin interface credentials.
      attribute(:admin_username, kind_of: String, default: 'admin')
      attribute(:admin_password, kind_of: String, default: 'admin')
      attribute(:admin_hostname, kind_of: String, default: 'localhost')
      attribute(:admin_port, kind_of: Integer, default: 6032)

      # PXC admin credentials for connecting to pxc-cluster-node.
      attribute(:cluster_username, kind_of: String, default: 'admin')
      attribute(:cluster_password, kind_of: String, default: 'admin')
      attribute(:cluster_hostname, kind_of: String, default: 'localhost')
      attribute(:cluster_port, kind_of: Integer, default: 3306)

      # ProxySQL monitoring user. proxysql admin script will create
      # this user in pxc to monitor pxc-nodes.
      attribute(:monitor_username, kind_of: String, default: 'admin')
      attribute(:monitor_password, kind_of: String, default: 'admin')

      # Application user to connect to pxc-node through proxysql
      attribute(:application_username, kind_of: String, default: 'admin')
      attribute(:application_password, kind_of: String, default: 'admin')

      # ProxySQL read/write hostgroup
      attribute(:read_hostgroup_id, kind_of: String, default: '10')
      attribute(:write_hostgroup_id, kind_of: String, default: '11')

      # ProxySQL read/write configuration mode.
      attribute(:read_write_mode, kind_of: String, default: 'singlewrite')
    end
  end

  class Provider
    class ProxysqlAdminConfig < ProxysqlBaseService
      provides(:proxysql_admin_config)

      def action_delete
        file admin_file do
          action :delete
        end
      end

      protected

      def deriver_install
        install_admin_config
      end

      private

      def admin_file_name
        "#{new_resource.name}-admin.cnf"
      end

      def admin_file
        ::File.join([new_resource.config_dir, admin_file_name])
      end

      # rubocop:disable Metrics/AbcSize
      def admin_variables
        {
          admin_username: new_resource.admin_username,
          admin_password: new_resource.admin_password,
          admin_hostname: new_resource.admin_hostname,
          admin_port: new_resource.admin_port,
          cluster_username: new_resource.cluster_username,
          cluster_password: new_resource.cluster_password,
          cluster_hostname: new_resource.cluster_hostname,
          cluster_port: new_resource.cluster_port,
          monitor_username: new_resource.monitor_username,
          monitor_password: new_resource.monitor_password,
          application_username: new_resource.application_username,
          application_password: new_resource.application_password,
          read_hostgroup_id: new_resource.read_hostgroup_id,
          write_hostgroup_id: new_resource.write_hostgroup_id,
          read_write_mode: new_resource.read_write_mode
        }
      end

      def install_admin_config
        variables = admin_variables
        template admin_file do
          source 'proxysql-admin.cnf.erb'
          variables variables
          owner new_resource.user
          group new_resource.group
          mode '0640'
          cookbook 'proxysql'
        end
      end
    end
  end
end
