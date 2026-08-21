require "rails_helper"

RSpec.describe Claims::Providers::ApproveRejectSamplingClaimWizard::MentorTrainingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(
      Claims::Providers::ApproveRejectSamplingClaimWizard,
      mentor_trainings:,
      action:,
    )
  end
  let(:action) { "reject" }
  let(:school) { create(:claims_school) }
  let(:provider) { create(:claims_provider) }
  let(:claim) { create(:claim, :submitted, provider:, school:, status: "sampling_in_progress") }
  let!(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:mentor_training) { create(:mentor_training, claim:, mentor:, provider:, hours_completed: 10) }
  let(:mentor_trainings) { claim.mentor_trainings.order_by_mentor_full_name }
  let(:attributes) { { mentor_id: mentor.id } }

  before { mentor_training }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_id: mentor.id, hours_option: nil, custom_hours: nil, reason_not_assured: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_id) }

    context "when the action is reject" do
      it { is_expected.to validate_presence_of(:hours_option) }
      it { is_expected.to validate_inclusion_of(:hours_option).in_array(described_class::HOURS_OPTIONS) }
      it { is_expected.to validate_presence_of(:reason_not_assured).with_message("Please enter a reason") }
    end

    context "when the action is approve" do
      let(:action) { "approve" }

      it { is_expected.not_to validate_presence_of(:hours_option) }
      it { is_expected.not_to validate_presence_of(:reason_not_assured) }
    end

    context "when custom hours are selected" do
      let(:attributes) do
        { mentor_id: mentor.id, hours_option: "custom", custom_hours:, reason_not_assured: "A reason" }
      end

      context "and the custom hours are within the available range" do
        let(:custom_hours) { "8" }

        it { is_expected.to be_valid }
      end

      context "and the custom hours are blank" do
        let(:custom_hours) { "" }

        it "is invalid with a range message" do
          expect(step).not_to be_valid
          expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 10")
        end
      end

      context "and the custom hours are not a number" do
        let(:custom_hours) { "abc" }

        it "is invalid with a range message" do
          expect(step).not_to be_valid
          expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 10")
        end
      end

      context "and the custom hours are outside the available range" do
        let(:custom_hours) { "11" }

        it "is invalid with a range message" do
          expect(step).not_to be_valid
          expect(step.errors[:custom_hours]).to include("Enter a number of hours between 1 and 10")
        end
      end
    end
  end

  describe "#mentor" do
    it "returns the mentor associated with the mentor id" do
      expect(step.mentor.id).to eq(mentor.id)
    end

    it "returns a Claims::Mentor instance" do
      expect(step.mentor).to be_a(Claims::Mentor)
    end

    it "memoizes the result" do
      first_call = step.mentor
      second_call = step.mentor
      expect(first_call).to be(second_call)
    end

    context "when mentor_training is nil" do
      let(:attributes) { { mentor_id: "non-existent-id" } }

      it "returns nil" do
        expect(step.mentor).to be_nil
      end
    end
  end

  describe "#completed_hours" do
    context "when all hours are removed" do
      let(:attributes) { { mentor_id: mentor.id, hours_option: "remove_all" } }

      it { expect(step.completed_hours).to eq(0) }
    end

    context "when custom hours are entered" do
      let(:attributes) { { mentor_id: mentor.id, hours_option: "custom", custom_hours: "6" } }

      it { expect(step.completed_hours).to eq(6) }
    end
  end

  describe "#max_hours" do
    context "when mentor_training exists" do
      let(:attributes) { { mentor_id: mentor.id } }

      it "returns the hours completed from the mentor training" do
        expect(step.max_hours).to eq(10)
      end
    end

    context "when mentor_training does not exist" do
      let(:attributes) { { mentor_id: "non-existent-id" } }

      it "returns 0" do
        expect(step.max_hours).to eq(0)
      end
    end
  end

  describe "clearing custom hours" do
    context "when custom hours are not selected" do
      let(:attributes) { { mentor_id: mentor.id, hours_option: "remove_all", custom_hours: "6" } }

      it "resets the custom hours" do
        expect(step.custom_hours).to be_nil
      end
    end
  end
end
