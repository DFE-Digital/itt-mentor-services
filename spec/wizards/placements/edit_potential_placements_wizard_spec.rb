require "rails_helper"

RSpec.describe Placements::EditPotentialPlacementsWizard do
  subject(:wizard) do
    described_class.new(
      state:,
      params:,
      school:,
      current_step:,
    )
  end

  let(:academic_year) { Placements::AcademicYear.current.next }
  let(:school) { create(:placements_school, potential_placement_details:) }
  let(:potential_placement_details) { {} }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    it { is_expected.to eq %i[phase note_to_providers confirm] }

    context "when the phase is set to 'Primary'" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Primary] },
        }
      end

      it {
        expect(steps).to eq %i[
          phase
          year_group_selection
          year_group_placement_quantity_known
          note_to_providers
          confirm
        ]
      }

      context "when the year group is selected and known" do
        let(:state) do
          {
            "phase" => { "phases" => %w[Primary] },
            "year_group_selection" => { "year_groups" => %w[year_1 year_2] },
            "year_group_placement_quantity_known" => { "quantity_known" => "Yes" },
          }
        end

        it {
          expect(steps).to eq %i[
            phase
            year_group_selection
            year_group_placement_quantity_known
            year_group_placement_quantity
            note_to_providers
            confirm
          ]
        }
      end
    end

    context "when the phase is set to 'Secondary'" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Secondary] },
        }
      end

      it {
        expect(steps).to eq %i[
          phase
          secondary_subject_selection
          secondary_placement_quantity_known
          note_to_providers
          confirm
        ]
      }

      context "when the secondary subject is select and quantity known" do
        let(:english) { create(:subject, :secondary, name: "English") }
        let(:state) do
          {
            "phase" => { "phases" => %w[Secondary] },
            "secondary_subject_selection" => { "subject_ids" => [english.id] },
            "secondary_placement_quantity_known" => { "quantity_known" => "Yes" },
          }
        end

        it {
          expect(steps).to eq %i[
            phase
            secondary_subject_selection
            secondary_placement_quantity_known
            secondary_placement_quantity
            note_to_providers
            confirm
          ]
        }
      end
    end

    context "when the phase is set to 'Primary' and 'Secondary'" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Primary Secondary] },
        }
      end

      it {
        expect(steps).to eq %i[
          phase
          year_group_selection
          year_group_placement_quantity_known
          secondary_subject_selection
          secondary_placement_quantity_known
          note_to_providers
          confirm
        ]
      }

      context "when the year group and secondary subjects are selected and quanitiy known" do
        let(:english) { create(:subject, :secondary, name: "English") }
        let(:state) do
          {
            "phase" => { "phases" => %w[Primary Secondary] },
            "year_group_selection" => { "year_groups" => %w[year_1 year_2] },
            "year_group_placement_quantity_known" => { "quantity_known" => "Yes" },
            "secondary_subject_selection" => { "subject_ids" => [english.id] },
            "secondary_placement_quantity_known" => { "quantity_known" => "Yes" },
          }
        end

        it {
          expect(steps).to eq %i[
            phase
            year_group_selection
            year_group_placement_quantity_known
            year_group_placement_quantity
            secondary_subject_selection
            secondary_placement_quantity_known
            secondary_placement_quantity
            note_to_providers
            confirm
          ]
        }
      end
    end
  end

  describe "#setup_state" do
    subject(:setup_state) { wizard.setup_state }

    let(:english) { create(:subject, :secondary, name: "English") }
    let(:science) { create(:subject, :secondary, name: "Science") }
    let(:school) { create(:placements_school, potential_placement_details:) }

    context "when the potential placement details includes quantities known" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[Primary Secondary] },
          "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
          "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
          "year_group_placement_quantity" => { "year_2" => 1, "year_3" => 2 },
          "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
          "secondary_placement_quantity" => { "english" => 1, "science" => 2 },
        }
      end

      it "returns a hash containing the attributes for the schools hosting interest" do
        setup_state
        expect(state).to eq(
          {
            "phase" => { "phases" => %w[Primary Secondary] },
            "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
            "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
            "year_group_placement_quantity_known" => { "quantity_known" => "Yes" },
            "year_group_placement_quantity" => { "year_2" => 1, "year_3" => 2 },
            "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
            "secondary_placement_quantity_known" => { "quantity_known" => "Yes" },
            "secondary_placement_quantity" => { "english" => 1, "science" => 2 },
          },
        )
      end
    end

    context "when the potential placement details do not include quantities known" do
      let(:potential_placement_details) do
        {
          "phase" => { "phases" => %w[Primary Secondary] },
          "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
          "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
          "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        }
      end

      it "returns a hash containing the attributes for the schools hosting interest" do
        setup_state
        expect(state).to eq(
          {
            "phase" => { "phases" => %w[Primary Secondary] },
            "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
            "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
            "year_group_placement_quantity_known" => { "quantity_known" => "No" },
            "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
            "secondary_placement_quantity_known" => { "quantity_known" => "No" },
          },
        )
      end
    end
  end

  describe "#update_potential_placements" do
    subject(:update_potential_placements) { wizard.update_potential_placements }

    let(:english) { create(:subject, :secondary, name: "English") }
    let(:science) { create(:subject, :secondary, name: "Science") }
    let(:potential_placement_details) do
      {
        "phase" => { "phases" => %w[Primary Secondary] },
        "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
        "year_group_selection" => { "year_groups" => %w[year_2] },
        "secondary_subject_selection" => { "subject_ids" => [english.id] },
      }
    end
    let(:school) { create(:placements_school, potential_placement_details:) }
    let(:state) do
      {
        "phase" => { "phases" => %w[Primary Secondary] },
        "note_to_providers" => { "note" => "Open to offering placements in English and Science" },
        "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
        "year_group_placement_quantity_known" => { "quantity_known" => "Yes" },
        "year_group_placement_quantity" => { "year_2" => 1, "year_3" => 2 },
        "secondary_subject_selection" => { "subject_ids" => [english.id, science.id] },
        "secondary_placement_quantity_known" => { "quantity_known" => "Yes" },
        "secondary_placement_quantity" => { "english" => 1, "science" => 2 },
      }
    end

    it "updates the schools potential placement details" do
      update_potential_placements
      school.reload
      updated_potential_placement_details = school.potential_placement_details
      expect(updated_potential_placement_details["phase"]).to eq({ "phases" => %w[Primary Secondary] })
      expect(updated_potential_placement_details["note_to_providers"]).to eq(
        { "note" => "Open to offering placements in English and Science" },
      )
      expect(updated_potential_placement_details["year_group_selection"]).to eq(
        { "year_groups" => %w[year_2 year_3] },
      )
      expect(updated_potential_placement_details["year_group_placement_quantity"]).to eq(
        { "year_2" => 1, "year_3" => 2 },
      )
      expect(updated_potential_placement_details["secondary_subject_selection"]).to eq(
        { "subject_ids" => [english.id, science.id] },
      )
      expect(updated_potential_placement_details["secondary_placement_quantity"]).to eq(
        { "english" => 1, "science" => 2 },
      )
    end
  end
end
