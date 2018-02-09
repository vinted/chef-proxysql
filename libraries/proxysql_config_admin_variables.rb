module ProxysqlConfig
  module AdminVariables
    # "admin_credentials": "admin:admin",
    # "mysql_ifaces": "127.0.0.1:6033"
    def config(admin_credentials:, mysql_ifaces:, config: {})
      {
        admin_credentials: admin_credentials,
        mysql_ifaces: mysql_ifaces
      }.merge(config)
    end
    module_function :config
  end
end
