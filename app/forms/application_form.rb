class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActionView::Helpers::TranslationHelper
  include Rails.application.routes.url_helpers

  def initialize(attributes = {})
    @virtual_path = "forms/#{self.class.name.underscore}"

    super
  end

  # Defaults to doing nothing and signaling a successful save.
  # Override this method in your subclass to implement your own persistence logic.
  # Side effects like sending notifications should not be triggered from this method.
  def persist
    true
  end

  def save
    validate ? persist : false
  end

  def save!
    validate ? persist : raise_validation_error
  end

  private

  def raise_validation_error
    raise ActiveModel::ValidationError, self
  end

  private_class_method def self.date_attribute(attribute_name)
    attribute :"#{attribute_name}(1i)", :integer
    attribute :"#{attribute_name}(2i)", :integer
    attribute :"#{attribute_name}(3i)", :integer

    alias_attribute :"#{attribute_name}_year", :"#{attribute_name}(1i)"
    alias_attribute :"#{attribute_name}_month", :"#{attribute_name}(2i)"
    alias_attribute :"#{attribute_name}_day", :"#{attribute_name}(3i)"

    define_method(attribute_name) do
      instance_variable_get("@#{attribute_name}") || begin
        year = send("#{attribute_name}_year")
        month = send("#{attribute_name}_month")
        day = send("#{attribute_name}_day")

        return nil if year.blank? || month.blank? || day.blank?

        instance_variable_set("@#{attribute_name}", Date.new(year, month, day))
      rescue ArgumentError, RangeError
        Struct.new(:year, :month, :day).new(year, month, day)
      end
    end

    define_method("#{attribute_name}=") do |value|
      value = ActiveModel::Type::Date.new.cast(value)

      send("#{attribute_name}_year=", value&.year)
      send("#{attribute_name}_month=", value&.month)
      send("#{attribute_name}_day=", value&.day)
    end
  end
end
