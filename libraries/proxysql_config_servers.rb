module ProxysqlConfig
  module Servers
    # "address": "127.0.0.1",
    # "port": 3306,
    # "hostgroup": 0,
    # "status": "ONLINE",
    # "weight": 1,
    # "compression": 0,
    # "max_replication_lag": 10
    def config(address:, port: 3306, hostgroup: 0, config: {})
      raise 'Provide Integer for hostgroup' unless hostgroup.is_a?(Integer)
      {
        address: address,
        hostgroup: hostgroup,
        port: port,
        status: 'ONLINE'
      }.merge(config)
    end
    module_function :config
  end
end
