class Placements::OrganisationSwitcherComponent < ApplicationComponent
  def initialize(user:, organisation:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @user = user
    @organisation = organisation
  end

  def title
    organisation.name
  end

  def change_organisation_link
    if user.support_user?
      placements_support_organisations_path
    elsif user.organisation_count > 1
      placements_organisations_path
    end
  end

  def academic_year
    user.selected_academic_year
  end

  private

  attr_reader :user, :organisation
end
