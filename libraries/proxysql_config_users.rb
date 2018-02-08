module ProxysqlConfig
  module Users
    # username VARCHAR NOT NULL,
    # password VARCHAR,
    # active INT CHECK (active IN (0,1)) NOT NULL DEFAULT 1,
    # use_ssl INT CHECK (use_ssl IN (0,1)) NOT NULL DEFAULT 0,
    # default_hostgroup INT NOT NULL DEFAULT 0,
    # default_schema VARCHAR,
    # schema_locked INT CHECK (schema_locked IN (0,1)) NOT NULL DEFAULT 0,
    # transaction_persistent INT CHECK (transaction_persistent IN (0,1)) NOT NULL DEFAULT 0,
    # fast_forward INT CHECK (fast_forward IN (0,1)) NOT NULL DEFAULT 0,
    # backend INT CHECK (backend IN (0,1)) NOT NULL DEFAULT 1,
    # frontend INT CHECK (frontend IN (0,1)) NOT NULL DEFAULT 1,
    # max_connections INT CHECK (max_connections >=0) NOT NULL DEFAULT 10000,
    def config(username:, password:, default_hostgroup: 0, config: {})
      unless default_hostgroup.is_a?(Integer)
        raise 'Provide Integer for default_hostgroup'
      end
      {
        username: username,
        password: password,
        active: 1,
        use_ssl: 0,
        default_hostgroup: default_hostgroup
      }.merge(config)
    end
    module_function :config
  end
end
