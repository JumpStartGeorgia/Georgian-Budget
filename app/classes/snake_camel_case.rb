class SnakeCamelCase
  def self.to_camel_case_sym(value)
    case value
    when Array
      value.map { |v| to_camel_case_sym(v) }
      # or `value.map(&method(:convert_hash_keys))`
    when Hash
      Hash[value.map { |k, v| [camelize_key(k), to_camel_case_sym(v)] }]
    else
      value
    end
  end

  private

  def self.camelize_key(k)
    k.to_s.camelize(:lower).to_sym
  end
end
