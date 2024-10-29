class Placement::StatusTagComponentPreview < ApplicationComponentPreview
  def placement_without_provider
    school = FactoryBot.build(:placements_school, with_school_contact: false)
    placement = FactoryBot.build(:placement, school:)

    render(Placement::StatusTagComponent.new(placement:))
  end

  def placement_with_provider
    provider = FactoryBot.build(:placements_provider)
    school = FactoryBot.build(:placements_school, with_school_contact: false)
    placement = FactoryBot.build(:placement, school:, provider:)

    render(Placement::StatusTagComponent.new(placement:))
  end
end
