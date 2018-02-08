module ProxysqlConfig
  module MysqlQueryRules
    # "rule_id": 1,
    # "active": 1,
    # "match_pattern": "^SELECT .* FOR UPDATE$",
    # "destination_hostgroup": 0,
    # "apply": 1
    def config(match_pattern:, config: {})
      validate(match_pattern: match_pattern)
      {
        match_pattern: match_pattern
      }.merge(config)
    end
    module_function :config

    def validate(match_pattern:)
      raise 'Provide String for match_pattern' unless match_pattern.is_a?(String)
      return unless (match_pattern =~ /^\^/).nil?
      raise 'match_pattern: must begin ^..'
    end
    module_function :validate
  end
end
