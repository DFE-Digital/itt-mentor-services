require "rails_helper"

describe Claims::Support::Claim::MentorsForm, type: :model do
  let!(:claim) { create(:claim) }
  let!(:mentor1) { create(:mentor) }
  let!(:mentor2) { create(:mentor) }

  describe "validations" do
    context "when mentors is blank" do
      it "returns invalid" do
        form = described_class.new(claim:)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:mentor_ids]).to include("Select a mentor")
      end
    end
  end

  describe "save" do
    it "creates mentor trainings on the claim" do
      mentor_ids = [mentor1, mentor2].map(&:id)
      form = described_class.new(claim:, mentor_ids:)

      expect {
        form.save!
      }.to change { claim.reload.mentor_trainings }.to match_array([
        have_attributes(mentor_id: mentor1.id, provider_id: claim.provider_id),
        have_attributes(mentor_id: mentor2.id, provider_id: claim.provider_id),
      ])
    end
  end

  describe "#update_success_path" do
    context "when there are mentors without mentor training hours" do
      it "returns the path to the mentor training hours form" do
        mentor_training = create(
          :mentor_training,
          claim:,
          mentor: mentor1,
        )
        form = described_class.new(claim:)

        expect(form.update_success_path).to eq(
          "/support/schools/#{claim.school_id}/claims/#{claim.id}/mentor_trainings/#{mentor_training.id}/edit",
        )
      end
    end

    context "when all mentors have mentor training hours" do
      it "returns the path to the claim check page" do
        if claim.mentor_trainings
          claim.mentor_trainings.update_all(hours_completed: 20)
        end
        form = described_class.new(claim:)

        expect(form.update_success_path).to eq(
          "/support/schools/#{claim.school_id}/claims/#{claim.id}/check",
        )
      end
    end
  end

  describe "#edit_back_path" do
    context "when reviewed is nil" do
      it "returns the path to the mentor training hours form" do
        form = described_class.new(claim:)

        expect(form.edit_back_path).to eq(
          "/support/schools/#{claim.school.id}/claims/#{claim.id}/edit",
        )
      end
    end

    context "when reviewed is true" do
      it "returns the path to the claim check page" do
        claim_reviewed = create(:claim, reviewed: true)
        form = described_class.new(claim: claim_reviewed)

        expect(form.update_success_path).to eq(
          "/support/schools/#{claim_reviewed.school.id}/claims/#{claim_reviewed.id}/check",
        )
      end
    end
  end
end
