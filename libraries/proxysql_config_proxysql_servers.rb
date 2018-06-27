module ProxysqlConfig
  module ProxySqlServers
    # "hostname": "127.0.0.1",
    # "port": 3306,
    # "weight": 1,
    # "comment": '',
    def config(hostname:, port: 6032, config: {})
      {
        hostname: hostname,
        port: port
      }.merge(config)
    end
    module_function :config
  end
end
