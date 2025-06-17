class Placements::MultiPlacementWizard::KeyStagePlacementQuantityStep < BaseStep
  validate :valid_quantities

  delegate :selected_key_stages, to: :wizard

  def initialize(wizard:, attributes:)
    define_key_stage_attributes(
      selected_key_stages: wizard.selected_key_stages,
      attributes: attributes,
    )

    super(
      wizard:,
      attributes: attributes&.select do |k, _v|
        wizard.selected_key_stages
        .map(&:name_as_attribute)
        .include?(k)
      end
    )
  end

  def key_stages
    selected_key_stages
  end

  def valid_quantities
    key_stages.each do |key_stage|
      key_stage_attribute = key_stage.name_as_attribute
      key_stage_quantity = try(key_stage_attribute)

      errors.add(key_stage_attribute, :blank, message: "#{key_stage.name} can't be blank") if key_stage_quantity.blank?
      errors.add(key_stage_attribute, :not_an_integer, message: "#{key_stage.name} must be a whole number") unless (key_stage_quantity.to_f % 1).zero?
      errors.add(key_stage_attribute, :greater_than, message: "#{key_stage.name} must be greater than 0") unless key_stage_quantity.to_i.positive?
    end
  end

  def assigned_variables
    key_stages.map { |attribute|
      { attribute.name_as_attribute.to_s => instance_variable_get("@#{attribute.name_as_attribute}") }
    }.reduce({}, :merge)
  end

  private

  def define_key_stage_attributes(selected_key_stages:, attributes:)
    selected_key_stages.each do |key_stage|
      singleton_class.class_eval { attr_accessor key_stage.name_as_attribute }
      instance_variable_set(
        "@#{key_stage.name_as_attribute}",
        attributes.blank? ? nil : attributes[key_stage.name_as_attribute.to_s],
      )
    end
  end
end
