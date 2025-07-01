class Placements::Schools::MapComponent < ApplicationComponent
  attr_reader :school

  def initialize(school:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @school = school
  end

  def render?
    school.latitude.present? && school.longitude.present?
  end
end
