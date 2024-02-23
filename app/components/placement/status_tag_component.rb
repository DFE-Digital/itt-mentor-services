class Placement::StatusTagComponent < ApplicationComponent
  attr_reader :placement_status

  # NOTE: valid colours for the TagComponent are %w(grey green turquoise blue light-blue red purple pink orange yellow)
  STATUS_COLOUR_MAP = {
    published: "blue",
    draft: "grey",
  }.freeze

  def initialize(placement_status, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @placement_status = placement_status
  end

  def call
    render GovukComponent::TagComponent.new(text: placement_status.capitalize,
                                            colour: STATUS_COLOUR_MAP.fetch(placement_status.to_sym, "grey"))
  end
end
