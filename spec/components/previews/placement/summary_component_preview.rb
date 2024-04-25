class Placement::SummaryComponentPreview < ApplicationComponentPreview
  def default
    provider = FactoryBot.create(:provider)
    subject_1 = FactoryBot.build(:subject, name: "Biology")
    subject_2 = FactoryBot.build(:subject, name: "Classics")
    school_1 = FactoryBot.create(
      :placements_school,
      phase: "Primary",
      minimum_age: "4",
      maximum_age: "11",
      gender: "Mixed",
      type_of_establishment: "Free school",
      religious_character: "Jewish",
      urban_or_rural: "Urban",
      rating: "Good",
      urn: Random.rand(1_000_000..10_000_000),
    )
    school_2 = FactoryBot.create(
      :placements_school,
      phase: "Secondary",
      minimum_age: "11",
      maximum_age: "17",
      gender: "Boys",
      type_of_establishment: "Community school",
      religious_character: "Christian",
      urban_or_rural: "Rural",
      rating: "Outstanding",
      urn: Random.rand(1_000_000..10_000_000),
    )
    mentor_1 = FactoryBot.create(:placements_mentor, schools: [])
    FactoryBot.create(
      :mentor_membership,
      :placements,
      mentor: mentor_1,
      school: school_1,
    )
    mentor_2 = FactoryBot.create(:placements_mentor, schools: [])
    FactoryBot.create(
      :mentor_membership,
      :placements,
      mentor: mentor_2,
      school: school_1,
    )
    placement_1 = FactoryBot.create(
      :placement,
      school: school_1,
      subjects: [subject_1],
      mentors: [mentor_1],
    )
    placement_2 = FactoryBot.create(
      :placement,
      school: school_2,
      subjects: [subject_2],
    )
    placement_3 = FactoryBot.create(
      :placement,
      school: school_1,
      subjects: [subject_1, subject_2],
      mentors: [mentor_1, mentor_2],
    )

    render(Placement::SummaryComponent.with_collection(
             [placement_1, placement_2, placement_3],
             provider:,
           ))
  end
end
