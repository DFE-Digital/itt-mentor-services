require "rails_helper"

RSpec.describe Placements::ConvertPotentialPlacementWizard::SelectPlacementStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::ConvertPotentialPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(potential_placement_details:, placement_count: 0)
    end
  end
  let(:attributes) { nil }
  let(:english) { create(:subject, :secondary, name: "English") }
  let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
  let(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
  let(:potential_placement_details) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(year_groups: [], subject_ids: []) }
  end

  describe "validations" do
    let(:potential_placement_details) do
      {
        "phase" => { "phases" => %w[primary secondary] },
        "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
        "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
        "secondary_subject_selection" => { "subject_ids" => [mathematics.id, english.id] },
        "secondary_placement_quantity" => { "mathematics" => 2, "english" => 1 },
      }
    end

    context "when no year groups are selected" do
      let(:attributes) { {} }

      it "raises a validation error for not selecting a year group" do
        expect(step.valid?).to be(false)
        expect(step.errors.messages[:year_groups]).to include("Primary placements can't be blank")
      end

      context "when a secondary subject is selected" do
        let(:attributes) { { subject_ids: [mathematics.id] } }

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end

    context "when no subjects are selected" do
      let(:attributes) { {} }

      it "raises a validation error for not selecting a secondary subject" do
        expect(step.valid?).to be(false)
        expect(step.errors.messages[:subject_ids]).to include("Secondary placements can't be blank")
      end

      context "when a year group is selected" do
        let(:attributes) { { year_groups: %w[year_2] } }

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#primary_year_groups" do
    subject(:primary_year_groups) { step.primary_year_groups }

    context "when the potential placement details contain no year groups selected" do
      it "returns an empty array" do
        expect(primary_year_groups).to eq([])
      end
    end

    context "when the potential placement details contains year groups selected" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary] },
          "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
          "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
        }
      end

      it "returns the selected year groups as OpenStruct objects" do
        expect(primary_year_groups).to eq([
          OpenStruct.new(value: "reception", name: "Reception", description: "4 to 5 years"),
          OpenStruct.new(value: "year_2", name: "Year 2", description: "6 to 7 years"),
          OpenStruct.new(value: "mixed_year_groups", name: "Mixed year groups", description: ""),
        ])
      end
    end
  end

  describe "#secondary_subjects" do
    subject(:secondary_subjects) { step.secondary_subjects }

    context "when the potential placement details contain no secondary subjects selected" do
      it "returns an empty array" do
        expect(secondary_subjects).to eq([])
      end
    end

    context "when the potential placement details contains secondary subjects selected" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[secondary] },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
        }
      end

      before { english }

      it "returns the selected secondary subjects" do
        expect(secondary_subjects).to contain_exactly(mathematics)
      end
    end
  end

  describe "#year_groups" do
    subject(:year_groups) { step.year_groups }

    context "when year_groups is blank" do
      let(:attributes) { { year_groups: [] } }

      it "returns an empty array" do
        expect(year_groups).to eq([])
      end
    end

    context "when the year_groups attribute contains a blank element" do
      let(:attributes) { { year_groups: ["year_1", nil] } }

      it "removes the nil element from the year_groups attribute" do
        expect(year_groups).to contain_exactly("year_1")
      end
    end

    context "when the year_groups attribute contains no blank elements" do
      let(:attributes) { { year_groups: %w[year_2 mixed_year_groups] } }

      it "returns the year_groups attribute unchanged" do
        expect(year_groups).to contain_exactly(
          "year_2",
          "mixed_year_groups",
        )
      end
    end
  end

  describe "#subject_ids" do
    subject(:subject_ids) { step.subject_ids }

    before do
      english
      mathematics
    end

    context "when subject_ids is blank" do
      let(:attributes) { { subject_ids: [] } }

      it "returns an empty array" do
        expect(subject_ids).to eq([])
      end
    end

    context "when the subject_ids attribute contains a blank element" do
      let(:attributes) { { subject_ids: [mathematics.id, nil] } }

      it "removes the nil element from the subject_ids attribute" do
        expect(subject_ids).to contain_exactly(mathematics.id)
      end
    end

    context "when the subject_ids attribute contains no blank elements" do
      let(:attributes) { { subject_ids: [mathematics.id, english.id] } }

      it "returns the subject_ids attribute unchanged" do
        expect(subject_ids).to contain_exactly(
          mathematics.id, english.id
        )
      end
    end
  end
end
