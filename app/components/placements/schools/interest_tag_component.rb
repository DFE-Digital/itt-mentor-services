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

  def initialize(school:, academic_year:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
    @academic_year = academic_year
  end

  def call
    render GovukComponent::TagComponent.new(text: interest_text, colour: interest_colour)
  end

  private

  attr_reader :school, :academic_year

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
    elsif open?
      "open"
    elsif not_looking?
      "not_open"
    else
      "not_participating"
    end
  end

  def actively_looking?
    school.current_hosting_interest(academic_year:)&.appetite == "actively_looking"
  end

  def open?
    school.current_hosting_interest(academic_year:)&.appetite == "interested"
  end

  def not_looking?
    school.current_hosting_interest(academic_year:)&.appetite == "not_open"
  end

  def only_has_unavailable_placements?
    @only_has_unavailable_placements ||= school.unavailable_placements(academic_year:).exists? && school.available_placements(academic_year:).empty?
  end

  def has_available_placements?
    @has_available_placements ||= school.available_placements(academic_year:).exists?
  end
end
