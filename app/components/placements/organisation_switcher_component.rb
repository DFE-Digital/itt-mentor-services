class Placements::OrganisationSwitcherComponent < ApplicationComponent
  def initialize(user:, organisation:, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @user = user
    @organisation = organisation
  end

  def call
    render ContentHeaderComponent.new(
      title: organisation.name,
      actions: [govuk_link_to(
        t(".change_organisation"),
        change_organisation_link,
        no_visited_state: true,
      )],
    )
  end

  def render?
    user.support_user? || user.organisation_count > 1
  end

  def change_organisation_link
    if user.support_user?
      placements_support_organisations_path
    else
      placements_organisations_path
    end
  end

  private

  attr_reader :user, :organisation
end
