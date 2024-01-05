module Placements::Support::SchoolsHelper
  def ofsted_field_args(value = nil)
    empty_state_value = I18n.t("placements.support.schools.show.unknown")
    field_args(value, empty_state_value)
  end

  def details_field_args(value = nil)
    empty_state_value = I18n.t("placements.support.schools.show.not_entered")
    field_args(value, empty_state_value)
  end

  private

  def field_args(value, empty_state_value)
    text = value.presence || empty_state_value
    classes = "govuk-hint" if empty_state_values.include? text
    { text:, classes: }.compact
  end

  def empty_state_values
    [I18n.t("placements.support.schools.show.not_entered"),
     I18n.t("placements.support.schools.show.unknown"),
     I18n.t("placements.support.schools.show.not_applicable")]
  end
end
