require "rails_helper"

RSpec.describe Claims::Providers::ApproveRejectSamplingClaimWizard::MentorStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::Providers::ApproveRejectSamplingClaimWizard, mentor_trainings:)
  end
  let(:school) { create(:claims_school) }
  let(:provider) { create(:claims_provider) }
  let(:claim) { create(:claim, :submitted, provider:, school:, status: "sampling_in_progress") }
  let!(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:mentor_training) { create(:mentor_training, claim:, mentor:, provider:, hours_completed: 10) }
  let(:mentor_trainings) { claim.mentor_trainings.order_by_mentor_full_name }
  let(:attributes) { nil }

  before { mentor_training }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_ids) }

    context "when a selected mentor does not belong to the claim" do
      let(:attributes) { { mentor_ids: [create(:claims_mentor).id] } }

      it { is_expected.not_to be_valid }
    end

    context "when the selected mentor belongs to the claim" do
      let(:attributes) { { mentor_ids: [mentor.id] } }

      it { is_expected.to be_valid }
    end
  end

  describe "#mentors" do
    it "returns the unique mentors from the claim's mentor trainings" do
      expect(step.mentors.map(&:id)).to contain_exactly(mentor.id)
    end
  end

  describe "#selected_mentors" do
    context "when mentor ids are selected" do
      let(:attributes) { { mentor_ids: [mentor.id] } }

      it "returns the selected mentors ordered by full name" do
        expect(step.selected_mentors).to contain_exactly(mentor)
      end
    end

    context "when there are no mentor trainings" do
      let(:mentor_trainings) { Claims::MentorTraining.none }

      it "returns no mentors" do
        expect(step.selected_mentors).to be_empty
      end
    end
  end

  describe "#mentor_ids=" do
    let(:attributes) { { mentor_ids: ["", mentor.id] } }

    it "removes blank values" do
      expect(step.mentor_ids).to eq([mentor.id])
    end
  end
end
