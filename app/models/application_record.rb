class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def valid_attributes?(*attributes)
    attributes.each do |attribute|
      self.class.validators_on(attribute).each do |validator|
        validator.validate_each(self, attribute, send(attribute))
      end
    end
    errors.none?
  end

  def invalid_attributes?(*attributes)
    !valid_attributes?(*attributes)
  end
end
