require "rails_helper"

RSpec.describe Placements::ConvertPotentialPlacementWizard do
  subject(:wizard) { described_class.new(state:, params:, school:, current_step:, current_user:) }

  let(:academic_year) { Placements::AcademicYear.current.next }
  let(:hosting_interest) do
    build(
      :hosting_interest,
      academic_year:,
      appetite: "interested",
    )
  end
  let(:school) { create(:placements_school, potential_placement_details:, hosting_interests: [hosting_interest]) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }
  let(:current_user) { create(:placements_user, selected_academic_year: academic_year) }
  let(:potential_placement_details) { nil }
  let(:english) { create(:subject, :secondary, name: "English") }
  let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
  let(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
  let(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
  let(:key_stage_5) { create(:key_stage, name: "Key stage 5") }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    context "when the potential_placement_details are nil" do
      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the phase is unknown" do
      let(:potential_placement_details) do
        { "phase" => { "phases" => %w[unknown] } }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the primary year group selection is unknown" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[unknown] },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the secondary subject selection is unknown" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
          "secondary_subject_selection" => { "subject_ids" => %w[unknown] },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the key stage selection is unknown" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[SEND] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
          "key_stage_selection" => { "key_stage_ids" => %w[unknown] },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the year group placement quantity is blank" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the secondary placement quantity is blank" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the key stage placement quantity is blank" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
        }
      end

      it { is_expected.to eq %i[phase check_your_answers] }
    end

    context "when the year group selection and quantity are present" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
        }
      end

      it { is_expected.to eq %i[convert_placement phase check_your_answers] }
    end

    context "when the key stage selection and quantity are present" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary] },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[convert_placement phase check_your_answers] }
    end

    context "when the secondary selection and quantity are present" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[secondary] },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
        }
      end

      it { is_expected.to eq %i[convert_placement phase check_your_answers] }
    end

    context "when the convert placement step is true" do
      let(:state) do
        { "convert_placement" => { "convert" => "Yes" } }
      end
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[year_2] },
          "year_group_placement_quantity" => { "year_2" => 2 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id] },
          "secondary_placement_quantity" => { "mathematics" => 2 },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2 },
        }
      end

      it { is_expected.to eq %i[convert_placement select_placement] }
    end
  end

  describe "#convert_placements" do
    subject(:convert_placements) { wizard.convert_placements }

    context "when the user has selected placements to be converted" do
      let(:state) do
        {
          "convert_placement" => { "convert" => "Yes" },
          "select_placement" => {
            "year_groups" => %w[year_2 mixed_year_groups],
            "subject_ids" => [mathematics.id],
            "key_stage_ids" => [key_stage_2.id],
          },
        }
      end
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
          "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id, english.id] },
          "secondary_placement_quantity" => { "mathematics" => 2, "english" => 1 },
          "key_stage_selection" => { "key_stage_ids" => [key_stage_2.id, key_stage_5.id] },
          "key_stage_placement_quantity" => { "key_stage_2" => 2, "key_stage_5" => 1 },
        }
      end

      before { primary }

      it "converts the selected potential placements to placements" do
        expect { convert_placements }.to change { school.placements.where(subject: primary, year_group: "year_2").count }.to(2)
          .and change { school.placements.where(subject: primary, year_group: "mixed_year_groups").count }.to(3)
          .and change { school.placements.where(subject: mathematics).count }.to(2)
          .and change { school.placements.where(key_stage: key_stage_2).count }.to(2)
          .and change { school.placements.count }.to(9)

        expect(hosting_interest.reload.appetite).to eq("actively_looking")
        expect(school.reload.potential_placement_details).to be_nil
      end

      context "when the selected placements have child subjects" do
        let(:modern_languages) { create(:subject, :secondary, name: "Modern Languages") }
        let(:french) { create(:subject, :secondary, name: "French", parent_subject: modern_languages) }
        let(:spanish) { create(:subject, :secondary, name: "Spanish", parent_subject: modern_languages) }
        let(:russian) { create(:subject, :secondary, name: "Russian", parent_subject: modern_languages) }
        let(:state) do
          {
            "convert_placement" => { "convert" => "Yes" },
            "select_placement" => {
              "subject_ids" => [modern_languages.id],
            },
          }
        end
        let(:potential_placement_details) do
          {
            "phase" => { "phases" => %w[secondary] },
            "secondary_subject_selection" => { "subject_ids" => [modern_languages.id] },
            "secondary_placement_quantity" => { "modern_languages" => 3 },
            "secondary_child_subject_placement_selection" => {
              "modern_languages" => {
                "1" => {
                  "selection_id" => "modern_languages_1",
                  "selection_number" => 1,
                  "child_subject_ids" => [french.id],
                  "parent_subject_id" => modern_languages.id,
                },
                "2" => {
                  "selection_id" => "modern_languages_2",
                  "selection_number" => 2,
                  "child_subject_ids" => [russian.id],
                  "parent_subject_id" => modern_languages.id,
                },
                "3" => {
                  "selection_id" => "modern_languages_3",
                  "selection_number" => 3,
                  "child_subject_ids" => [french.id, spanish.id],
                  "parent_subject_id" => modern_languages.id,
                },
              },
            },
          }
        end

        it "converts the selected potential placements to placements" do
          placements = school.placements.joins(:additional_subjects)
          expect { convert_placements }.to change { school.placements.where(subject: modern_languages).count }.to(3)
            .and change { placements.where(additional_subjects: { id: french.id }).count }.to(2)
            .and change { placements.where(additional_subjects: { id: russian.id }).count }.to(1)
            .and change { placements.where(additional_subjects: { id: [spanish.id] }).count }.to(1)
        end
      end
    end

    context "when the user has not selected placements to be converted" do
      let(:state) do
        {
          "convert_placement" => { "convert" => "No" },
          "phase" => { "phases" => %w[Primary Secondary] },
          "year_group_selection" => { "year_groups" => %w[year_3] },
          "year_group_placement_quantity" => { "year_3" => "1" },
          "secondary_subject_selection" => { "subject_ids" => [english.id] },
          "secondary_placement_quantity" => { "english" => "3" },
        }
      end
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[primary secondary] },
          "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
          "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
          "secondary_subject_selection" => { "subject_ids" => [mathematics.id, english.id] },
          "secondary_placement_quantity" => { "mathematics" => 2, "english" => 1 },
        }
      end

      before { primary }

      it "converts the selected potential placements to placements" do
        expect { convert_placements }.to change { school.placements.where(subject: primary, year_group: "year_3").count }.to(1)
          .and change { school.placements.where(subject: english).count }.to(3)
          .and change { school.placements.count }.to(4)

        expect(hosting_interest.reload.appetite).to eq("actively_looking")
        expect(school.reload.potential_placement_details).to be_nil
      end
    end
  end

  describe "#placement_count" do
    subject(:placement_count) { wizard.placement_count(phase:, key:) }

    let(:potential_placement_details) do
      {
        "phase" => { "phases" => %w[primary secondary] },
        "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
        "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
        "secondary_subject_selection" => { "subject_ids" => [mathematics.id, english.id] },
        "secondary_placement_quantity" => { "mathematics" => 2, "english" => 1 },
      }
    end

    context "when given the phase 'primary'" do
      let(:phase) { :primary }

      context "when given a year group included in the year_group_placement_quantity key" do
        let(:key) { "reception" }

        it "returns the number assigned to the year group key" do
          expect(placement_count).to eq(1)
        end
      end

      context "when given a key not in the year_group_placement_quantity" do
        let(:key) { "english" }

        it "returns zero" do
          expect(placement_count).to eq(0)
        end
      end
    end
  end

  describe "#academic_year" do
    subject(:wizard_academic_year) { wizard.academic_year }

    it "returns the selected academic year of the user" do
      expect(wizard_academic_year).to eq(academic_year)
    end
  end

  describe "#convert?" do
    subject(:to_convert) { wizard.convert? }

    let(:potential_placement_details) do
      {
        "phase" => { "phases" => %w[primary secondary] },
        "year_group_selection" => { "year_groups" => %w[reception year_2 mixed_year_groups] },
        "year_group_placement_quantity" => { "reception" => 1, "year_2" => 2, "mixed_year_groups" => 3 },
        "secondary_subject_selection" => { "subject_ids" => [mathematics.id, english.id] },
        "secondary_placement_quantity" => { "mathematics" => 2, "english" => 1 },
      }
    end

    context "when the convert placement step is set to 'Yes'" do
      let(:state) do
        {
          "convert_placement" => { "convert" => "Yes" },
        }
      end

      it "returns true" do
        expect(to_convert).to be(true)
      end
    end

    context "when the convert placement step is set to 'No'" do
      let(:state) do
        {
          "convert_placement" => { "convert" => "No" },
        }
      end

      it "returns true" do
        expect(to_convert).to be(false)
      end
    end
  end
end
