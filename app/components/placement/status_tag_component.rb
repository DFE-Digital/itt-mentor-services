class Placement::StatusTagComponent < ApplicationComponent
  def initialize(placement:, viewed_by_organisation:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @placement = placement
    @viewed_by_organisation = viewed_by_organisation
  end

  private

  attr_reader :placement, :viewed_by_organisation

  def status
    if assigned_to_viewed_by_organisation?
      { colour: "blue", text: I18n.t("placements.schools.placements.assigned_to_you") }
    elsif placement_has_provider? && viewed_by_organisation_type == :school
      { colour: "blue", text: I18n.t("placements.schools.placements.assigned_to_provider") }
    elsif placement_has_provider?
      { colour: "red", text: I18n.t("placements.schools.placements.unavailable") }
    else
      { colour: "green", text: I18n.t("placements.schools.placements.available") }
    end
  end

  def status_colour
    status[:colour]
  end

  def status_text
    status[:text]
  end

  def assigned_to_viewed_by_organisation?
    placement_has_provider? && placement.provider.id == viewed_by_organisation.id
  end

  def placement_has_provider?
    placement.provider.present?
  end

  def viewed_by_organisation_type
    @viewed_by_organisation_type ||= viewed_by_organisation.is_a?(Placements::School) ? :school : :provider
  end
end
