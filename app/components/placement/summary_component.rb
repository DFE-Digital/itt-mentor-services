class Placement::SummaryComponent < ApplicationComponent
  with_collection_parameter :placement
  attr_reader :placement, :school, :provider

  def initialize(provider:, placement:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @provider = provider
    @placement = placement.decorate
    @school = @placement.school
  end
end
