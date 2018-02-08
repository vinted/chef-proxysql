module ProxysqlHelpers
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  def to_cnf(obj, comma: false)
    output = StringIO.new
    case obj
    when Hash
      output.puts '{'
      obj.each do |k, v|
        output.puts "  #{k}=#{to_cnf(v)}"
      end
      output.puts "}#{comma ? ',' : ''}"
    when Array
      last = obj.last

      output.puts '('
      obj.each do |val|
        output.puts to_cnf(val, comma: last != val)
      end
      output.puts ')'
    when String
      output.puts "\"#{obj}\""
    when Symbol
      output.puts "\"#{obj}\""
    when Integer || Float
      output.puts obj
    when TrueClass || FalseClass
      output.puts obj.to_s
    else
      Chef::Log.warn "proxsql: Object #{obj} of class #{obj.class} "\
        'is not supported interpreting as a String'
      output.puts "\"#{obj}\""
    end
    output.string
  end

  def for_instance(instance, config)
    {
      instance => config.is_a?(Array) ? config : [config]
    }
  end
  module_function :for_instance
end
