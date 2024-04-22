class BetweenValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    min_value = options[:min].is_a?(Symbol) ? record.send(options[:min]) : options[:min]
    max_value = options[:max].is_a?(Symbol) ? record.send(options[:max]) : options[:max]

    unless value.to_f.between?(min_value, max_value)
      record.errors.add(attribute, :between, min: min_value, max: max_value)
    end
  end
end
