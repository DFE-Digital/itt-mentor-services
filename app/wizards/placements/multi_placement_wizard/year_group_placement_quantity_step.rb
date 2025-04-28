class Placements::MultiPlacementWizard::YearGroupPlacementQuantityStep < BaseStep
  validate :valid_quantities

  delegate :year_groups, to: :wizard

  def initialize(wizard:, attributes:)
    define_year_group_attributes(
      selected_year_groups: wizard.year_groups,
      attributes: attributes,
    )

    super(wizard:, attributes:)
  end

  def valid_quantities
    year_groups.each do |year_group|
      year_group_attribute = year_group.to_sym
      year_group_quantity = try(year_group_attribute)
      year_group_name = I18n.t("placements.schools.placements.year_groups.#{year_group}")

      errors.add(year_group_attribute, :blank, message: "#{year_group_name} can't be blank") if year_group_quantity.blank?
      errors.add(year_group_attribute, :not_an_integer, message: "#{year_group_name} must be a whole number") unless (year_group_quantity.to_f % 1).zero?
      errors.add(year_group_attribute, :greater_than, message: "#{year_group_name} must be greater than 0") unless year_group_quantity.to_i.positive?
    end
  end

  def assigned_variables
    year_groups.map { |attribute|
      { attribute => instance_variable_get("@#{attribute.to_sym}") }
    }.reduce({}, :merge)
  end

  private

  def define_year_group_attributes(selected_year_groups:, attributes:)
    selected_year_groups.each do |year_group|
      singleton_class.class_eval { attr_accessor year_group.to_sym }
      instance_variable_set(
        "@#{year_group.to_sym}",
        attributes.blank? ? nil : attributes[year_group],
      )
    end
  end
end
