module ProxysqlConfig
  module MysqlVariables
    # "threads": 4,
    # "max_connections": 2048,
    # "default_query_delay": 0,
    # "default_query_timeout": 36000000,
    # "have_compress": true,
    # "poll_timeout": 2000,
    # "interfaces": "0.0.0.0:6033",
    # "default_schema": "information_schema",
    # "stacksize": 1048576,
    # "server_version": "5.5.30",
    # "connect_timeout_server": 3000,
    # "monitor_username": "monitor",
    # "monitor_password": "monitor",
    # "monitor_history": 600000,
    # "monitor_connect_interval": 60000,
    # "monitor_ping_interval": 10000,
    # "monitor_read_only_interval": 1500,
    # "monitor_read_only_timeout": 500,
    # "ping_interval_server_msec": 120000,
    # "ping_timeout_server": 500,
    # "commands_stats": true,
    # "sessions_sort": true,
    # "connect_retries_on_failure": 10
    def config(
      monitor_username:,
      monitor_password:,
      interfaces: '0.0.0.0:6033',
      config: {}
    )
      raise 'Provide String for monitor_username' unless monitor_username.is_a?(String)
      raise 'Provide String for monitor_password' unless monitor_password.is_a?(String)
      {
        monitor_username: monitor_username,
        monitor_password: monitor_password,
        interfaces: interfaces
      }.merge(config)
    end
    module_function :config
  end
end
