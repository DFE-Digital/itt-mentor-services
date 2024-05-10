class Placement::StatusTagComponent < ApplicationComponent
  def initialize(placement:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @placement = placement
  end

  private

  attr_reader :placement

  def status_colour
    placement.provider.present? ? "orange" : "turquoise"
  end

  def status_text
    placement.provider.present? ? I18n.t("placements.schools.placements.unavailable") : I18n.t("placements.schools.placements.available")
  end
end
