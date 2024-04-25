class Placement::SummaryComponent < ApplicationComponent
  with_collection_parameter :placement
  attr_reader :placement, :school

  def initialize(placement:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @placement = placement.decorate
    @school = placement.school.decorate
  end
end
