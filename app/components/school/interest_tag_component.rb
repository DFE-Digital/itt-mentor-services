class School::InterestTagComponent < ApplicationComponent
  def initialize(school:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
  end

  private

  attr_reader :school

  INTEREST_COLOURS = {
    "open" => "yellow",
    "unfilled_placements" => "green",
    "filled_placements" => "blue",
    "not_open" => "red",
  }.freeze

  INTEREST_TEXT = {
    "open" => I18n.t("components.school.interest_tag_component.interested"),
    "unfilled_placements" => I18n.t("components.school.interest_tag_component.actively_looking"),
    "filled_placements" => I18n.t("components.school.interest_tag_component.already_organised"),
    "not_open" => I18n.t("components.school.interest_tag_component.not_open"),
  }.freeze

  private_constant :INTEREST_COLOURS, :INTEREST_TEXT

  def calculated_status
    if school.current_hosting_interest_appetite == "actively_looking" && (school.unavailable_placement_subjects.exists? && school.available_placement_subjects.empty?)
      "filled_placements"
    elsif school.current_hosting_interest_appetite == "actively_looking" && school.available_placement_subjects.exists?
      "unfilled_placements"
    elsif school.current_hosting_interest_appetite == "actively_looking"
      "open"
    elsif school.current_hosting_interest_appetite == "not_open"
      "not_open"
    end
  end

  def interest_colour
    INTEREST_COLOURS[calculated_status]
  end

  def interest_text
    INTEREST_TEXT[calculated_status]
  end

  def render_interest_tag?
    school.current_hosting_interest_appetite.present? && school.current_hosting_interest_appetite != "already_organised"
  end
end
