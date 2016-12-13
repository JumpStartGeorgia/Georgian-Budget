module FactoryGirlHelpers
  def attributes_with_foreign_keys(*args)
    inst = FactoryGirl.build(*args)
    attrs = inst.attributes
    attrs.delete_if do |k, v|
      ["id", "type", "created_at", "updated_at"].member?(k)
    end
    inst.class.defined_enums.each { |k, v| attrs[k] = inst.send(k) }
    return attrs.deep_transform_keys(&:to_sym)
  end
end

RSpec.configure do |config|
  config.include FactoryGirlHelpers
end
