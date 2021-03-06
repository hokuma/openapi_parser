class OpenAPIParser::SchemaValidator
  class ObjectValidator < Base
    # @param [Hash] value
    # @param [OpenAPIParser::Schemas::Schema] schema
    def coerce_and_validate(value, schema)
      return OpenAPIParser::ValidateError.build_error_result(value, schema) unless value.kind_of?(Hash)

      return [value, nil] unless schema.properties

      required_set = schema.required ? schema.required.to_set : Set.new

      coerced_values = value.map do |name, v|
        s = schema.properties[name]
        coerced, err = validatable.validate_schema(v, s)
        return [nil, err] if err

        required_set.delete(name)
        [name, coerced]
      end

      return [nil, OpenAPIParser::NotExistRequiredKey.new(required_set.to_a, schema.object_reference)] unless required_set.empty?

      value.merge!(coerced_values.to_h) if @coerce_value

      [value, nil]
    end
  end
end
