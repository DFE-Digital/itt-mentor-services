require "rails_helper"

RSpec.describe Claims::AddClaimWizard::MentorTrainingStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddClaimWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        provider:,
        academic_year: claim_window.academic_year,
        steps: { mentor: mentor_step },
        claim_to_exclude: nil,
      )
    end
  end
  let(:mentor_step) do
    instance_double(Claims::AddClaimWizard::MentorStep).tap do |mentor_step|
      allow(mentor_step).to receive(:mentor_ids).and_return([mentor.id])
      allow(mentor_step).to receive_messages(
        mentor_ids: [mentor.id],
        selected_mentors: Claims::Mentor.where(id: mentor.id),
      )
    end
  end
  let(:school) { create(:claims_school) }
  let(:provider) { create(:claims_provider) }
  let!(:mentor) { create(:claims_mentor, schools: [school]) }
  let(:claim_window) { Claims::ClaimWindow.current || create(:claim_window, :current) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(mentor_id: nil, hours_to_claim: nil, custom_hours: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:mentor_id) }
    it { is_expected.to validate_presence_of(:hours_to_claim) }
    it { is_expected.to validate_inclusion_of(:hours_to_claim).in_array(described_class::HOURS_TO_CLAIM) }

    context "when custom are selected" do
      let(:attributes) { { hours_to_claim: "custom", mentor_id: mentor.id } }

      it do
        expect(step).to validate_numericality_of(:custom_hours)
          .only_integer
          .is_greater_than_or_equal_to(1)
          .is_less_than_or_equal_to(20)
          .with_message("Enter the number of hours between 1 and 20")
      end
    end

    context "when custom are not selected" do
      let(:attributes) { { hours_to_claim: "maximum", mentor_id: mentor.id } }

      it { is_expected.to be_valid }
      it { is_expected.not_to validate_presence_of(:custom_hours) }
    end

    describe "delegations" do
      it { is_expected.to delegate_method(:provider).to(:wizard) }
      it { is_expected.to delegate_method(:name).to(:provider).with_prefix(true) }
      it { is_expected.to delegate_method(:full_name).to(:mentor).with_prefix(true) }
    end
  end

  describe "#mentor" do
    context "when a mentor id is given" do
      let(:attributes) { { mentor_id: mentor.id } }

      it "return the mentor associated with the given mentor id" do
        expect(step.mentor).to eq(mentor)
      end
    end

    context "when a mentor id is not given" do
      it "return the mentor associated with the given mentor id" do
        expect(step.mentor).to be_nil
      end
    end
  end

  describe "#training_allowance" do
    subject(:training_allowance) { step.training_allowance }

    let(:attributes) { { mentor_id: mentor.id } }

    it "returns the training allowance for a given mentor" do
      expect(training_allowance).to be_a(Claims::TrainingAllowance)
    end
  end

  describe "#max_hours" do
    subject(:max_hours) { step.max_hours }

    let(:attributes) { { mentor_id: mentor.id } }

    context "when the mentor has no previous training hours with the provider" do
      it "returns the maximum number of hours" do
        expect(max_hours).to eq(20)
      end
    end

    context "when the mentor has previous training hours with the provider" do
      before do
        existing_claim = create(:claim, :submitted, provider:, school:, claim_window:)
        create(:mentor_training,
               claim: existing_claim,
               hours_completed: 1,
               mentor:,
               provider:,
               date_completed: claim_window.starts_on)
      end

      it "returns the remaining number of claimable hours" do
        expect(max_hours).to eq(19)
      end
    end
  end

  describe "#hours_completed" do
    subject(:hours_completed) { step.hours_completed }

    context "when custom hours completed is present" do
      let(:attributes) { { mentor_id: mentor.id, custom_hours: 6, hours_to_claim: "custom" } }

      it "returns hours completed" do
        expect(hours_completed).to eq(6)
      end
    end

    context "when custom hours completed is not present" do
      let(:attributes) { { mentor_id: mentor.id, hours_to_claim: "maximum", custom_hours: 6 } }

      it "returns hours completed" do
        expect(hours_completed).to eq(20)
      end
    end
  end
end
