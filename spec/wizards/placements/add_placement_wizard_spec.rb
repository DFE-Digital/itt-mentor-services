require "rails_helper"

RSpec.describe Placements::AddPlacementWizard do
  subject(:wizard) { described_class.new(state:, params:, school:, current_step:) }

  let(:current_step) { nil }

  # Schools
  let(:primary_school) { build(:placements_school, :primary, mentors:) }
  let(:secondary_school) { build(:placements_school, :secondary, mentors:) }
  let(:all_through_school) { build(:placements_school, phase: "All-through", mentors:) }

  # Subjects
  let(:drama) { create(:subject, :secondary, name: "Drama") }
  let(:modern_foreign_languages) { create(:subject, :secondary, name: "Modern foreign languages", child_subjects: [french, german]) }
  let(:french) { build(:subject, :secondary, name: "French") }
  let(:german) { build(:subject, :secondary, name: "German") }
  let(:primary) { create(:subject, :primary, name: "Primary") }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:school) { secondary_school }
  let(:mentors) { build_list(:placements_mentor, 5) }

  describe "#steps" do
    subject { wizard.steps.keys }

    context "with a primary school" do
      let(:school) { primary_school }

      it { is_expected.to eq %i[year_group academic_year terms mentors check_your_answers] }
    end

    context "with a secondary school" do
      let(:school) { secondary_school }

      it { is_expected.to eq %i[secondary_subject_selection academic_year terms mentors check_your_answers] }
    end

    context "with an all-through school" do
      let(:school) { all_through_school }

      it { is_expected.to eq %i[phase academic_year terms mentors check_your_answers] }

      context "when the Primary phase has been chosen" do
        let(:state) { { "phase" => { "phase" => "Primary" } } }

        it { is_expected.to eq %i[phase year_group academic_year terms mentors check_your_answers] }
      end

      context "when the Secondary phase has been chosen" do
        let(:state) { { "phase" => { "phase" => "Secondary" } } }

        it { is_expected.to eq %i[phase secondary_subject_selection academic_year terms mentors check_your_answers] }
      end
    end

    context "when there are no mentors" do
      let(:school) { secondary_school }
      let(:mentors) { [] }

      it { is_expected.to eq %i[secondary_subject_selection academic_year terms check_your_answers] }
    end

    context "when the chosen subject has child subjects" do
      let(:school) { secondary_school }
      let(:state) { { "secondary_subject_selection" => { "subject_id" => modern_foreign_languages.id } } }

      it { is_expected.to eq %i[secondary_subject_selection additional_subjects academic_year terms mentors check_your_answers] }
    end

    context "when the preview placement step is active" do
      let(:current_step) { :preview_placement }

      it { is_expected.to eq %i[secondary_subject_selection academic_year terms mentors check_your_answers preview_placement] }
    end
  end

  describe "#create_placement" do
    subject(:placement) { wizard.create_placement }

    let(:selected_mentor) { school.mentors.sample }
    let(:academic_year) { create(:placements_academic_year) }
    let(:mentor_not_known) { Placements::AddPlacementWizard::MentorsStep::NOT_KNOWN }

    context "when primary with a mentor" do
      let(:school) { primary_school }
      let(:state) do
        {
          "year_group" => { "year_group" => "year_3" },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
          "mentors" => { "mentor_ids" => [selected_mentor.id] },
        }
      end

      before { primary }

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(primary)
        expect(placement.year_group).to eq("year_3")
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to eq [selected_mentor]
      end
    end

    context "when primary with unknown mentor" do
      let(:school) { primary_school }
      let(:state) do
        {
          "year_group" => { "year_group" => "year_3" },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
          "mentors" => { "mentor_ids" => mentor_not_known },
        }
      end

      before { primary }

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(primary)
        expect(placement.year_group).to eq("year_3")
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to be_empty
      end
    end

    context "when secondary with a mentor" do
      let(:school) { secondary_school }
      let(:state) do
        {
          "secondary_subject_selection" => { "subject_id" => drama.id },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
          "mentors" => { "mentor_ids" => [selected_mentor.id] },
        }
      end

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(drama)
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to eq [selected_mentor]
      end
    end

    context "when secondary with unknown mentor" do
      let(:school) { secondary_school }
      let(:state) do
        {
          "secondary_subject_selection" => { "subject_id" => drama.id },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
          "mentors" => { "mentor_ids" => mentor_not_known },
        }
      end

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(drama)
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to be_empty
      end
    end

    context "when secondary with additional subjects" do
      let(:school) { secondary_school }
      let(:state) do
        {
          "secondary_subject_selection" => { "subject_id" => modern_foreign_languages.id },
          "additional_subjects" => { "additional_subject_ids" => [french.id, german.id] },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
          "mentors" => { "mentor_ids" => mentor_not_known },
        }
      end

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(modern_foreign_languages)
        expect(placement.additional_subjects).to contain_exactly(french, german)
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to be_empty
      end
    end

    context "when the school has no mentors" do
      let(:school) { secondary_school }
      let(:mentors) { [] }
      let(:state) do
        {
          "secondary_subject_selection" => { "subject_id" => drama.id },
          "academic_year" => { "academic_year_id" => academic_year.id },
          "terms" => { "term_ids" => %w[any_term] },
        }
      end

      it "creates a placement" do
        expect(placement).to be_persisted
        expect(placement.subject).to eq(drama)
        expect(placement.academic_year).to eq(academic_year)
        expect(placement.mentors).to be_empty
      end
    end

    context "when there are invalid steps" do
      let(:school) { secondary_school }

      context "when not mentor is given in the mentors step" do
        let(:state) do
          {
            "secondary_subject_selection" => { "subject_id" => drama.id },
            "terms" => { "term_ids" => %w[any_term] },
            "mentors" => { "mentor_ids" => [] }, # invalid
          }
        end

        it "raises an error" do
          expect { wizard.create_placement }.to raise_error "Invalid wizard state"
        end
      end

      context "when no term is given in the terms step" do
        let(:state) do
          {
            "secondary_subject_selection" => { "subject_id" => drama.id },
            "terms" => { "term_ids" => [] },
          }
        end

        it "raises an error" do
          expect { wizard.create_placement }.to raise_error "Invalid wizard state"
        end
      end
    end
  end

  describe "#placement_phase" do
    subject { wizard.placement_phase }

    context "with a primary school" do
      let(:school) { primary_school }

      it { is_expected.to eq "Primary" }
    end

    context "with a secondary school" do
      let(:school) { secondary_school }

      it { is_expected.to eq "Secondary" }
    end

    context "with an all-through school" do
      let(:school) { all_through_school }

      context "when the phase step has not been answered yet" do
        it { is_expected.to eq all_through_school.phase }
      end

      context "when Primary was chosen in the phase step" do
        let(:state) { { "phase" => { "phase" => "Primary" } } }

        it { is_expected.to eq "Primary" }
      end

      context "when Secondary was chosen in the phase step" do
        let(:state) { { "phase" => { "phase" => "Secondary" } } }

        it { is_expected.to eq "Secondary" }
      end
    end
  end

  describe "#subject" do
    subject { wizard.subject }

    before { primary }

    context "with a primary school" do
      let(:school) { primary_school }

      it { is_expected.to eq(primary) }
    end

    context "with a secondary school" do
      let(:school) { secondary_school }
      let(:state) { { "secondary_subject_selection" => { "subject_id" => drama.id } } }

      before { french }

      it { is_expected.to eq(drama) }
    end

    context "with an all-through school" do
      let(:school) { all_through_school }

      before { french }

      context "when the phase step has not been answered yet" do
        it { is_expected.to be_nil }
      end

      context "when Primary was chosen in the phase step" do
        let(:state) { { "phase" => { "phase" => "Primary" } } }

        it { is_expected.to eq(primary) }
      end

      context "when secondary was chosen in the phase step and drama was chosen in the secondary subject selection step" do
        let(:state) do
          { "phase" => { "phase" => "Secondary" },
            "secondary_subject_selection" => { "subject_id" => drama.id } }
        end

        it { is_expected.to eq(drama) }
      end
    end
  end
end
