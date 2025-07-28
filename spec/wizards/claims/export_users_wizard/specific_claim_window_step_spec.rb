require "rails_helper"

RSpec.describe Claims::ExportUsersWizard::SpecificClaimWindowStep, type: :model do
  subject(:step) { described_class.new(wizard:, attributes:) }

  let(:wizard) { instance_double(Claims::ExportUsersWizard) }
  let(:attributes) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(claim_window_id: nil) }
  end

  describe "validations" do
    let!(:valid_window) { create(:claim_window, :current) }

    context "when claim_window_id is valid" do
      before { step.claim_window_id = valid_window.id }

      it "is valid" do
        expect(step).to be_valid
      end
    end

    context "when claim_window_id is blank" do
      before { step.claim_window_id = nil }

      it "is invalid with a custom message" do
        expect(step).to be_invalid
        expect(step.errors[:claim_window_id]).to include("Select a claim window")
      end
    end
  end

  describe "#available_claim_windows" do
    subject(:claim_windows) { step.available_claim_windows }

    let!(:current) { create(:claim_window, :current).decorate }
    let!(:upcoming) { create(:claim_window, :upcoming).decorate }
    let!(:historic) { create(:claim_window, :historic).decorate }

    it "returns all claim windows" do
      expect(claim_windows.map(&:id)).to contain_exactly(current.id, upcoming.id, historic.id)
    end
  end
end
