class Placements::Schools::InterestTagComponent < ApplicationComponent
  INTEREST_COLOURS = {
    "open" => "yellow",
    "unfilled_placements" => "green",
    "filled_placements" => "blue",
    "not_open" => "red",
    "not_participating" => "grey",
  }.freeze

  INTEREST_TEXT = {
    "open" => I18n.t("components.placements.schools.interest_tag_component.open"),
    "unfilled_placements" => I18n.t("components.placements.schools.interest_tag_component.unfilled_placements"),
    "filled_placements" => I18n.t("components.placements.schools.interest_tag_component.filled_placements"),
    "not_open" => I18n.t("components.placements.schools.interest_tag_component.not_open"),
    "not_participating" => I18n.t("components.placements.schools.interest_tag_component.not_participating"),
  }.freeze

  private_constant :INTEREST_COLOURS, :INTEREST_TEXT

  def initialize(school:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
  end

  private

  attr_reader :school

  def interest_colour
    INTEREST_COLOURS[calculated_status]
  end

  def interest_text
    INTEREST_TEXT[calculated_status]
  end

  def calculated_status
    if actively_looking? && only_has_unavailable_placements?
      "filled_placements"
    elsif actively_looking? && has_available_placements?
      "unfilled_placements"
    elsif actively_looking?
      "open"
    elsif not_looking?
      "not_open"
    else
      "not_participating"
    end
  end

  def actively_looking?
    school.current_hosting_interest_appetite == "actively_looking"
  end

  def not_looking?
    school.current_hosting_interest_appetite == "not_open"
  end

  def only_has_unavailable_placements?
    @only_has_unavailable_placements ||= school.unavailable_placements.exists? && school.available_placements.empty?
  end

  def has_available_placements?
    @has_available_placements ||= school.available_placements.exists?
  end
end
