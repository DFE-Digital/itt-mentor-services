class Placement::SummaryComponentPreview < ApplicationComponentPreview
  def default
    provider = FactoryBot.build_stubbed(:provider)
    school = FactoryBot.build(
      :placements_school,
      with_school_contact: false,
      phase: "Primary",
      group: "Academies",
      rating: "Good",
    )
    placement_1 = FactoryBot.build_stubbed(
      :placement,
      school:,
      year_group: :year_1,
    )

    render(Placement::SummaryComponent.with_collection(
             [placement_1],
             provider:,
           ))
  end

  def with_location_search
    provider = FactoryBot.build_stubbed(:provider)
    school = FactoryBot.build(
      :placements_school,
      with_school_contact: false,
      phase: "Primary",
      group: "Academies",
      rating: "Good",
      longitude: -0.1888492108,
      latitude: 51.4472362417,
    )
    placement_1 = FactoryBot.build_stubbed(
      :placement,
      school: school.decorate,
      year_group: :year_1,
    )

    render(Placement::SummaryComponent.with_collection(
             [placement_1],
             provider:,
             search_location: "London",
             location_coordinates: [51.5072178, -0.1275862],
           ))
  end
end
