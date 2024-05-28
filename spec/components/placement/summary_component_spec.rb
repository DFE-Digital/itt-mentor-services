require "rails_helper"

RSpec.describe Placement::SummaryComponent, type: :component do
  subject(:component) do
    described_class.with_collection(placements, provider:, location_coordinates:)
  end

  let(:subject_1) { create(:subject, name: "Biology") }
  let(:subject_2) { create(:subject, name: "Classics") }
  let(:school) do
    create(
      :placements_school,
      name: "London Primary School",
      phase: "All-through",
      minimum_age: "4",
      maximum_age: "11",
      gender: "Mixed",
      group: "Local authority maintained schools",
      religious_character: "Jewish",
      urban_or_rural: "(England/Wales) Urban city and town",
      rating: "Good",
      latitude: 51.23622,
      longitude: -0.570409,
    )
  end
  let(:placement_1) { create(:placement, school:, subject:, mentors:) }
  let(:placement_2) { create(:placement, school:, subject: subject_2, mentors:) }
  let(:provider) { create(:provider) }

  context "when given multiple placements" do
    let(:subject) { subject_1 }
    let(:mentors) { [] }
    let(:placements) { [placement_1, placement_2] }
    let(:location_coordinates) { nil }

    it "renders the details of each placement" do
      render_inline(component)

      # School details
      expect(page).to have_content("London Primary School", count: 2)
      expect(page).to have_content("All-through", count: 2)
      expect(page).to have_content("4 to 11", count: 2)
      expect(page).to have_content("Mixed", count: 2)
      expect(page).to have_content("Local authority maintained schools", count: 2)
      expect(page).to have_content("Jewish", count: 2)
      expect(page).to have_content("(England/Wales) Urban city and town", count: 2)
      expect(page).to have_content("Good", count: 2)

      # Subject details
      expect(page).to have_content("Biology", count: 1)
      expect(page).to have_content("Classics", count: 1)
    end
  end

  context "when given a single placement" do
    let(:subject) { subject_1 }
    let(:placements) { [placement_1] }

    context "when the placement has subject with no child subjects" do
      let(:mentors) { [] }
      let(:location_coordinates) { nil }

      it "renders the placement's subjects as a sentence" do
        render_inline(component)

        # Subject details
        expect(page).to have_content("Biology")
      end
    end

    context "when the placement has subject with child subjects" do
      let(:mentors) { [] }
      let(:location_coordinates) { nil }
      let(:subject) { subject_1 }
      let(:subject_1) { create(:subject, name: "Modern Foreign Languages") }
      let(:additional_subject_1) { create(:subject, name: "French", parent_subject: subject_1) }
      let(:additional_subject_2) { create(:subject, name: "German", parent_subject: subject_1) }
      let(:additional_subject_3) { create(:subject, name: "Spanish", parent_subject: subject_1) }
      let(:placement_1) { create(:placement, school:, subject: subject_1, additional_subjects: [additional_subject_1]) }

      it "renders the placement's subjects as a sentence" do
        render_inline(component)

        # Subject details
        expect(page).to have_content("French")
      end

      context "with 2 additional subject do" do
        let(:subject) { subject_1 }
        let(:placement_1) { create(:placement, school:, subject: subject_1, additional_subjects: [additional_subject_1, additional_subject_2]) }

        it "renders the placement's subjects as a sentence" do
          render_inline(component)

          # Subject details
          expect(page).to have_content("French and German")
        end
      end

      context "with 3 additional subjects do" do
        let(:placement_1) { create(:placement, school:, subject: subject_1, additional_subjects: [additional_subject_1, additional_subject_2, additional_subject_3]) }

        it "renders the placement's subjects as a sentence" do
          render_inline(component)
          # Subject details
          expect(page).to have_content("French, German, and Spanish")
        end
      end
    end
  end

  context "when giving location coordinates to the component" do
    let(:location_coordinates) { [51.5072178, -0.1275862] }
    let(:subject) { subject_1 }
    let(:mentors) { [] }
    let(:placements) { [placement_1] }

    it "renders the distance between the placement's school and the coordinates" do
      render_inline(component)

      # Distance details
      expect(page).to have_content(26.7)
    end
  end
end
