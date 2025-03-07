class School::InterestTagComponent < ApplicationComponent
  def initialize(school:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
  end

  private

  attr_reader :school

  INTEREST_COLOURS = {
    "actively_looking" => "green",
    "interested" => "yellow",
    "not_open" => "red",
  }.freeze

  INTEREST_TEXT = {
    "actively_looking" => I18n.t("components.school.interest_tag_component.actively_looking"),
    "interested" => I18n.t("components.school.interest_tag_component.interested"),
    "not_open" => I18n.t("components.school.interest_tag_component.not_open"),
  }.freeze

  private_constant :INTEREST_COLOURS, :INTEREST_TEXT

  def interest_colour
    INTEREST_COLOURS[school.current_hosting_interest_appetite]
  end

  def interest_text
    INTEREST_TEXT[school.current_hosting_interest_appetite]
  end

  def render_interest_tag?
    school.current_hosting_interest_appetite.present? && school.current_hosting_interest_appetite != "already_organised"
  end
end
