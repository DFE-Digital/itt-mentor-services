module DateAttributes
  extend ActiveSupport::Concern

  IncompleteDate = Struct.new(:year, :month, :day)

  class_methods do
    private

    def date_attribute(attribute_name)
      attr_accessor :"#{attribute_name}_year", :"#{attribute_name}_month", :"#{attribute_name}_day"

      alias_method :"#{attribute_name}(1i)", :"#{attribute_name}_year"
      alias_method :"#{attribute_name}(2i)", :"#{attribute_name}_month"
      alias_method :"#{attribute_name}(3i)", :"#{attribute_name}_day"

      alias_method :"#{attribute_name}(1i)=", :"#{attribute_name}_year="
      alias_method :"#{attribute_name}(2i)=", :"#{attribute_name}_month="
      alias_method :"#{attribute_name}(3i)=", :"#{attribute_name}_day="

      define_method "#{attribute_name}=" do |value|
        attribute_value = ActiveModel::Type::Date.new.cast(value)

        raise ArgumentError, "Invalid date format" unless attribute_value.is_a?(Date) || attribute_value.nil?

        send("#{attribute_name}_year=", attribute_value&.year)
        send("#{attribute_name}_month=", attribute_value&.month)
        send("#{attribute_name}_day=", attribute_value&.day)
      end

      define_method attribute_name do
        year, month, day = %w[year month day].map { |date_part| send("#{attribute_name}_#{date_part}") }

        if [year, month, day].all?(&:present?)
          Date.new(year.to_i, month.to_i, day.to_i)
        elsif [year, month, day].any?(&:present?)
          IncompleteDate.new(year, month, day)
        end
      end

      define_method "#{attribute_name}_is_date?" do
        send(attribute_name).is_a?(Date)
      end
    end
  end
end
