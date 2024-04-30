require "rails_helper"

RSpec.describe Placement::SummaryComponent, type: :component do
  subject(:component) do
    described_class.with_collection(placements, provider:)
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
      type_of_establishment: "Free school",
      religious_character: "Jewish",
      urban_or_rural: "(England/Wales) Urban city and town",
      rating: "Good",
    )
  end
  let(:placement_1) { create(:placement, school:, subjects:, mentors:) }
  let(:placement_2) { create(:placement, school:, subjects: [subject_2], mentors:) }
  let(:provider) { create(:provider) }

  context "when given multiple placements" do
    let(:subjects) { [subject_1] }
    let(:mentors) { [] }
    let(:placements) { [placement_1, placement_2] }

    it "renders the details of each placement" do
      render_inline(component)

      # School details
      expect(page).to have_content("London Primary School", count: 2)
      expect(page).to have_content("All-through", count: 2)
      expect(page).to have_content("4 to 11", count: 2)
      expect(page).to have_content("Mixed", count: 2)
      expect(page).to have_content("Free school", count: 2)
      expect(page).to have_content("Jewish", count: 2)
      expect(page).to have_content("(England/Wales) Urban city and town", count: 2)
      expect(page).to have_content("Good", count: 2)

      # Subject details
      expect(page).to have_content("Biology", count: 1)
      expect(page).to have_content("Classics", count: 1)

      # Mentor details
      expect(page).to have_content("Not yet known", count: 2)
    end
  end

  context "when given a single placements" do
    let(:placements) { [placement_1] }

    context "when the placement has multiple subject" do
      let(:mentors) { [] }

      context "with 2 subjects do" do
        let(:subjects) { [subject_1, subject_2] }

        it "renders the placement's subjects as a sentence" do
          render_inline(component)

          # Subject details
          expect(page).to have_content("Biology and Classics")
        end
      end

      context "with 3 subjects do" do
        let(:subject_3) { create(:subject, name: "Physics") }
        let(:subjects) { [subject_1, subject_2, subject_3] }

        it "renders the placement's subjects as a sentence" do
          render_inline(component)

          # Subject details
          expect(page).to have_content("Biology, Classics, and Physics")
        end
      end
    end

    context "when the placement has mentors" do
      let(:subjects) { [subject_1] }
      let(:mentor_1) { create(:placements_mentor, schools: [], first_name: "Joe", last_name: "Bloggs") }
      let(:mentor_2) { create(:placements_mentor, schools: [], first_name: "Jane", last_name: "Doe") }
      let(:mentor_3) { create(:placements_mentor, schools: [], first_name: "Jack", last_name: "Sprat") }

      context "with 1 mentor" do
        let(:mentors) { [mentor_1] }

        before do
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_1,
            school:,
          )
        end

        it "renders the placement mentor's full name" do
          render_inline(component)

          # Mentor details
          expect(page).to have_content("Joe Bloggs")
        end
      end

      context "with 2 mentors" do
        let(:mentors) { [mentor_1, mentor_2] }

        before do
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_1,
            school:,
          )
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_2,
            school:,
          )
        end

        it "renders the placement mentor's full name" do
          render_inline(component)

          # Mentor details
          expect(page).to have_content("Jane Doe and Joe Bloggs")
        end
      end

      context "with 3 mentors" do
        let(:mentors) { [mentor_1, mentor_2, mentor_3] }

        before do
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_1,
            school:,
          )
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_2,
            school:,
          )
          create(
            :mentor_membership,
            :placements,
            mentor: mentor_3,
            school:,
          )
        end

        it "renders the placement mentor's full name" do
          render_inline(component)

          # Mentor details
          expect(page).to have_content("Jack Sprat, Jane Doe, and Joe Bloggs")
        end
      end
    end
  end
end
