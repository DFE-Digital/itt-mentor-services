require "rails_helper"

RSpec.describe Claims::UploadESFAClawbackResponseWizard::UploadErrorsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::UploadESFAClawbackResponseWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(clawback_in_progress_claims: Claims::Claim.clawback_in_progress, steps: { upload: mock_upload_step })
    end
  end
  let(:mock_upload_step) do
    instance_double(Claims::UploadESFAClawbackResponseWizard::UploadStep).tap do |mock_upload_step|
      allow(mock_upload_step).to receive_messages(
        invalid_claim_references:,
        invalid_status_claim_references:,
        missing_mentor_training_claim_references:,
        missing_reason_clawed_back_claim_references:,
        invalid_hours_clawed_back_claim_references:,
      )
    end
  end
  let(:attributes) { nil }
  let(:invalid_claim_references) { nil }
  let(:invalid_status_claim_references) { nil }
  let(:missing_mentor_training_claim_references) { nil }
  let(:missing_reason_clawed_back_claim_references) { nil }
  let(:invalid_hours_clawed_back_claim_references) { nil }
  let(:claim_1) { create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111) }
  let(:claim_2) { create(:claim, :submitted, status: :clawback_in_progress, reference: 22_222_222) }
  let(:claim_3) { create(:claim, :submitted, status: :clawback_in_progress, reference: 33_333_333) }

  before do
    claim_1
    claim_2
    claim_3
  end

  describe "#invalid_status_claims" do
    subject(:invalid_status_claims) { step.invalid_status_claims }

    context "when the upload step invalid_claim_references attribute is nil" do
      it "returns an empty array" do
        expect(invalid_status_claims).to eq([])
      end
    end

    context "when the upload step invalid_claim_references attribute contains a reference" do
      let(:invalid_status_claim_references) { %w[11111111 22222222] }

      it "returns a list of claims with the references in the invalid_claim_references attribute" do
        expect(invalid_status_claims).to contain_exactly(claim_1, claim_2)
      end
    end
  end

  describe "#missing_mentor_claims" do
    subject(:missing_mentor_claims) { step.missing_mentor_claims }

    context "when the upload step missing_mentor_training_claim_references attribute is nil" do
      it "returns an empty array" do
        expect(missing_mentor_claims).to eq([])
      end
    end

    context "when the upload step missing_mentor_training_claim_references attribute contains a reference" do
      let(:missing_mentor_training_claim_references) { %w[11111111 22222222] }

      it "returns a list of claims with the references in the missing_mentor_training_claim_references attribute" do
        expect(missing_mentor_claims).to contain_exactly(claim_1, claim_2)
      end
    end
  end

  describe "#missing_reason_clawed_back_claims" do
    subject(:missing_reason_clawed_back_claims) { step.missing_reason_clawed_back_claims }

    context "when the upload step missing_reason_clawed_back_claim_references attribute is nil" do
      it "returns an empty array" do
        expect(missing_reason_clawed_back_claims).to eq([])
      end
    end

    context "when the upload step missing_reason_clawed_back_claim_references attribute contains a reference" do
      let(:missing_reason_clawed_back_claim_references) { %w[11111111 22222222] }

      it "returns a list of claims with the references in the missing_reason_clawed_back_claim_references attribute" do
        expect(missing_reason_clawed_back_claims).to contain_exactly(claim_1, claim_2)
      end
    end
  end

  describe "#invalid_hours_clawed_back_claims" do
    subject(:invalid_hours_clawed_back_claims) { step.invalid_hours_clawed_back_claims }

    context "when the upload step invalid_hours_clawed_back_claim_references attribute is nil" do
      it "returns an empty array" do
        expect(invalid_hours_clawed_back_claims).to eq([])
      end
    end

    context "when the upload step invalid_hours_clawed_back_claim_references attribute contains a reference" do
      let(:invalid_hours_clawed_back_claim_references) { %w[11111111 22222222] }

      it "returns a list of claims with the references in the invalid_hours_clawed_back_claim_references attribute" do
        expect(invalid_hours_clawed_back_claims).to contain_exactly(claim_1, claim_2)
      end
    end
  end
end
