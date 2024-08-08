class DatePresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.errors.add(attribute, :blank) unless value.is_a?(Date)
  end
end
