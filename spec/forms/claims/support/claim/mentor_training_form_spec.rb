require "rails_helper"

describe Claims::Support::Claim::MentorTrainingForm, type: :model do
  subject(:mentor_training_form) { described_class.new(claim: mentor_training.claim, mentor_training:, hours_completed:, custom_hours_completed:) }

  let(:hours_completed) { nil }
  let(:custom_hours_completed) { nil }

  let(:mentor_training) { create(:mentor_training, mentor: create(:claims_mentor, first_name: "Bobby"), hours_completed: mentor_hours_completed) }
  let(:mentor_hours_completed) { nil }

  describe "validations" do
    it { is_expected.to validate_presence_of(:hours_completed) }

    context "when hours_completed is 20" do
      let(:hours_completed) { 20 }

      it { is_expected.to be_valid }
      it { is_expected.not_to validate_presence_of(:custom_hours_completed) }
    end

    context "when hours_completed is less than 20" do
      let(:hours_completed) { 19 }

      it { is_expected.to be_valid }
      it { is_expected.to validate_presence_of(:custom_hours_completed) }

      it do
        expect(mentor_training_form).to validate_numericality_of(:custom_hours_completed)
          .only_integer
          .is_greater_than_or_equal_to(1)
          .is_less_than_or_equal_to(20)
          .with_message("Enter the number of hours between 1 and 20")
      end
    end

    context "when a mentor has already claimed 1 hour of mentor training" do
      let(:submitted_claim) { create(:claim, :submitted) }

      before do
        create(
          :mentor_training,
          claim: submitted_claim,
          provider: mentor_training.provider,
          mentor: mentor_training.mentor,
          hours_completed: 1,
        )
      end

      context "when hours_completed is 20" do
        let(:hours_completed) { 20 }

        it { is_expected.not_to be_valid }
      end

      context "when hours_completed is 19" do
        let(:hours_completed) { 19 }

        it { is_expected.to be_valid }
        it { is_expected.not_to validate_presence_of(:custom_hours_completed) }
      end

      context "when hours_completed is less than 19" do
        let(:hours_completed) { 10 }

        it { is_expected.to be_valid }
        it { is_expected.to validate_presence_of(:custom_hours_completed) }

        it do
          expect(mentor_training_form).to validate_numericality_of(:custom_hours_completed)
            .only_integer
            .is_greater_than_or_equal_to(1)
            .is_less_than_or_equal_to(19)
            .with_message("Enter the number of hours between 1 and 19")
        end
      end
    end
  end

  describe "#save" do
    it "saves the hours_completed to the mentor_training" do
      expect { mentor_training_form.save! }.to raise_error(ActiveModel::ValidationError)
    end

    context "when hours_completed is 20" do
      let(:hours_completed) { 20 }

      it "saves the hours_completed to the mentor_training" do
        expect { mentor_training_form.save! }.to change { mentor_training.reload.hours_completed }.from(nil).to(20)
      end
    end

    context "when custom_hours_completed is 20" do
      let(:hours_completed) { "custom" }
      let(:custom_hours_completed) { 20 }

      it "saves the hours_completed to the mentor_training" do
        expect { mentor_training_form.save! }.to change { mentor_training.reload.hours_completed }.from(nil).to(20)
      end
    end

    context "when editing an existing claim" do
      let(:mentor_hours_completed) { 6 }
      let(:hours_completed) { 16 }

      it "saves the hours_completed to the mentor_training" do
        expect { mentor_training_form.save! }.to change { mentor_training.reload.hours_completed }.from(6).to(16)
      end
    end
  end

  describe "#back_path" do
    context "when we are on the alphabetically-first mentor training hours page" do
      it "returns the path to the mentors check list" do
        expect(mentor_training_form.back_path).to eq(
          "/support/schools/#{mentor_training.claim.school_id}/claims/#{mentor_training.claim.id}/mentors/edit",
        )
      end
    end

    context "when we are on the alphabetically-second mentor training hours page" do
      let!(:existing_mentor_training) { create(:mentor_training, claim: mentor_training.claim, mentor: create(:claims_mentor, first_name: "Anne")) }

      it "returns the path to the first mentor training" do
        expect(mentor_training_form.back_path).to eq(
          "/support/schools/#{mentor_training.claim.school_id}/claims/#{mentor_training.claim.id}/mentor_trainings/#{existing_mentor_training.id}/edit",
        )
      end
    end
  end

  describe "#success_path" do
    let(:mentor_hours_completed) { 20 }

    context "when there are no more mentor trainings without hours completed" do
      it "returns the path to the check page" do
        expect(mentor_training_form.success_path).to eq(
          "/support/schools/#{mentor_training.claim.school_id}/claims/#{mentor_training.claim.id}/check",
        )
      end
    end

    context "when there are mentor trainings without hours completed" do
      let!(:existing_mentor_training_without_hours) { create(:mentor_training, claim: mentor_training_form.claim) }

      it "returns the path to the next mentor training hours" do
        expect(mentor_training_form.success_path).to eq(
          "/support/schools/#{mentor_training.claim.school_id}/claims/#{mentor_training.claim.id}/mentor_trainings/#{existing_mentor_training_without_hours.id}/edit",
        )
      end
    end
  end

  describe "#max_hours_equals_maximum_claimable_hours?" do
    it "returns true when a mentor has 20 hours available to claim" do
      expect(mentor_training_form.max_hours_equals_maximum_claimable_hours?).to eq(true)
    end

    context "when a mentor has already claimed any amount of hours" do
      let(:submitted_claim) { create(:claim, :submitted) }

      before do
        create(
          :mentor_training,
          claim: submitted_claim,
          provider: mentor_training.provider,
          mentor: mentor_training.mentor,
          hours_completed: 1,
        )
      end

      it "returns false" do
        expect(mentor_training_form.max_hours_equals_maximum_claimable_hours?).to eq(false)
      end
    end
  end
end
