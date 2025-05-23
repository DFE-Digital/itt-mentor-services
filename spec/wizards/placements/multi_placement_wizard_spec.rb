require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard do
  subject(:wizard) { described_class.new(state:, params:, school:, current_step:) }

  let(:school) { create(:placements_school) }
  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    subject(:steps) { wizard.steps.keys }

    it { is_expected.to eq %i[phase check_your_answers] }

    context "when the phase is set to 'Primary' during the phase step" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Primary] },
        }
      end

      it {
        expect(steps).to eq(
          %i[phase
             year_group_selection
             year_group_placement_quantity
             check_your_answers],
        )
      }
    end

    context "when the phase is set to 'Secondary' during the phase step" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Secondary] },
        }
      end

      it {
        expect(steps).to eq(
          %i[phase
             secondary_subject_selection
             secondary_placement_quantity
             check_your_answers],
        )
      }

      context "when the subject selected has child subjects" do
        let(:modern_languages) { create(:subject, :secondary, name: "Modern Languages") }
        let(:french) { create(:subject, :secondary, name: "French", parent_subject: modern_languages) }
        let(:state) do
          {
            "phase" => { "phases" => %w[Secondary] },
            "secondary_subject_selection" => { "subject_ids" => [modern_languages.id] },
            "secondary_placement_quantity" => { "modern_languages" => "2" },
          }
        end

        before { french }

        it {
          expect(steps).to eq(
            %i[phase
               secondary_subject_selection
               secondary_placement_quantity
               secondary_child_subject_placement_selection_modern_languages_1
               secondary_child_subject_placement_selection_modern_languages_2
               check_your_answers],
          )
        }
      end
    end

    context "when the phase is set to 'Primary' and 'Secondary' during the phase step" do
      let(:state) do
        {
          "phase" => { "phases" => %w[Primary Secondary] },
        }
      end

      it {
        expect(steps).to eq(
          %i[phase
             year_group_selection
             year_group_placement_quantity
             secondary_subject_selection
             secondary_placement_quantity
             check_your_answers],
        )
      }
    end
  end

  describe "#update_school_placements" do
    subject(:update_school_placements) { wizard.update_school_placements }

    before { school }

    context "when the attributes passed are valid" do
      context "when the phase selected is 'Primary'" do
        let!(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
        let(:state) do
          {
            "phase" => { "phases" => %w[Primary] },
            "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
            "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
          }
        end

        it "creates a placement for each selected subject and it's quantity" do
          expect { update_school_placements }.to change(Placement, :count).by(6)
          school.reload

          primary_placements = school.placements.where(subject_id: primary.id)
          expect(primary_placements.count).to eq(6)
          expect(primary_placements.where(year_group: "reception").count).to eq(1)
          expect(primary_placements.where(year_group: "year_3").count).to eq(2)
          expect(primary_placements.where(year_group: "mixed_year_groups").count).to eq(3)
        end
      end

      context "when the phase selected is 'Secondary'" do
        let(:english) { create(:subject, :secondary, name: "English") }
        let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
        let(:state) do
          {
            "phase" => { "phases" => %w[Secondary] },
            "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
            "secondary_placement_quantity" => { "english" => "2", "mathematics" => "3" },
          }
        end

        it "creates a placement for each selected subject and it's quantity" do
          expect { update_school_placements }.to change(Placement, :count).by(5)
          school.reload

          expect(school.placements.where(subject_id: english.id).count).to eq(2)
          expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)
        end

        context "when a selected subject has child subjects" do
          let(:statistics) { create(:subject, :secondary, name: "Statistics", parent_subject: mathematics) }
          let(:mechanics) { create(:subject, :secondary, name: "Mechanics", parent_subject: mathematics) }
          let(:state) do
            {
              "phase" => { "phases" => %w[Secondary] },
              "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
              "secondary_placement_quantity" => { "mathematics" => "2", "english" => "1" },
              "secondary_child_subject_placement_selection_mathematics_1" => {
                "child_subject_ids" => [statistics.id, mechanics.id],
              },
              "secondary_child_subject_placement_selection_mathematics_2" => {
                "child_subject_ids" => [statistics.id],
              },
            }
          end

          it "creates a placement for each selected subject and it's quantity,
            plus assigning the selected child subjects" do
            expect { update_school_placements }.to change(Placement, :count).by(3)
            school.reload

            expect(school.placements.where(subject_id: english.id).count).to eq(1)

            mathematics_placements = school.placements.where(subject_id: mathematics.id)
            expect(mathematics_placements.count).to eq(2)
            expect(
              mathematics_placements.map { |placement| placement.additional_subjects.pluck(:name) },
            ).to contain_exactly(%w[Statistics], %w[Statistics Mechanics])
          end
        end
      end

      context "when the phase selected is 'Primary' and 'Secondary'" do
        let!(:primary) { create(:subject, :primary, name: "Primary", code: "00") }
        let(:english) { create(:subject, :secondary, name: "English") }
        let(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
        let(:state) do
          {
            "phase" => { "phases" => %w[Primary Secondary] },
            "year_group_selection" => { "year_groups" => %w[reception year_3 mixed_year_groups] },
            "year_group_placement_quantity" => { "reception" => "1", "year_3" => "2", "mixed_year_groups" => "3" },
            "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
            "secondary_placement_quantity" => { "english" => "2", "mathematics" => "3" },
          }
        end

        it "creates a placement for each selected subject and it's quantity" do
          expect { update_school_placements }.to change(Placement, :count).by(11)
          school.reload

          primary_placements = school.placements.where(subject_id: primary.id)
          expect(primary_placements.count).to eq(6)
          expect(primary_placements.where(year_group: "reception").count).to eq(1)
          expect(primary_placements.where(year_group: "year_3").count).to eq(2)
          expect(primary_placements.where(year_group: "mixed_year_groups").count).to eq(3)

          expect(school.placements.where(subject_id: english.id).count).to eq(2)
          expect(school.placements.where(subject_id: mathematics.id).count).to eq(3)
        end
      end
    end

    context "when a step is invalid" do
      let(:state) do
        {
          "phase" => { "phases" => nil },
        }
      end

      it "returns an error" do
        expect { update_school_placements }.to raise_error "Invalid wizard state"
      end
    end
  end

  describe "#upcoming_academic_year" do
    subject(:upcoming_academic_year) { wizard.upcoming_academic_year }

    let(:next_academic_year) { Placements::AcademicYear.current.next }

    before { next_academic_year }

    it "returns the next academic year" do
      expect(upcoming_academic_year).to eq(next_academic_year)
    end
  end

  describe "#selected_secondary_subjects" do
    subject(:selected_secondary_subjects) { wizard.selected_secondary_subjects }

    context "when a secondary subject has not been selected" do
      it "returns an empty array" do
        expect(selected_secondary_subjects).to eq([])
      end
    end

    context "when a secondary subject has been selected" do
      let(:primary_subject) { create(:subject, :primary, name: "Primary", code: "00") }
      let!(:english) { create(:subject, :secondary, name: "English") }
      let!(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
      let(:science) { create(:subject, :secondary, name: "Science") }
      let(:state) do
        {
          "phase" => { "phases" => %w[Secondary] },
          "secondary_subject_selection" => { "subject_ids" => [english.id, mathematics.id] },
        }
      end

      before do
        science
        primary_subject
      end

      it "returns a list of selected secondary subjects" do
        expect(selected_secondary_subjects).to contain_exactly(english, mathematics)
      end
    end
  end
end
