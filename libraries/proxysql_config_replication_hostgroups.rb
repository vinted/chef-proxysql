module ProxysqlConfig
  module ReplicationHostgroups
    # writer_hostgroup INT
    # reader_hostgroup INT NOT NULL
    # comment VARCHAR,
    def config(writer_hostgroup:, reader_hostgroup:, comment: '')
      raise 'Provide Integer for writer_hostgroup' unless writer_hostgroup.is_a?(Integer)
      raise 'Provide Integer for reader_hostgroup' unless reader_hostgroup.is_a?(Integer)
      {
        writer_hostgroup: writer_hostgroup,
        reader_hostgroup: reader_hostgroup,
        comment: comment
      }
    end
    module_function :config
  end
end
