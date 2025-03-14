class Placements::OrganisationSwitcherComponentPreview < ApplicationComponentPreview
  def default
    user = FactoryBot.build(:placements_support_user)
    organisation = FactoryBot.build(:placements_school, with_school_contact: false)

    render(Placements::OrganisationSwitcherComponent.new(user:, organisation:))
  end
end
