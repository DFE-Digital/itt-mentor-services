require "rails_helper"

RSpec.describe Claims::OnboardMultipleSchoolsWizard::ClaimWindowStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::OnboardMultipleSchoolsWizard)
  end
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(claim_window_id: nil) }
  end

  describe "validations" do
    let(:current_claim_window) { create(:claim_window, :current) }
    let(:upcoming_claim_window) { create(:claim_window, :upcoming) }
    let!(:valid_claim_window_ids) { [current_claim_window.id, upcoming_claim_window.id] }

    it { is_expected.to validate_inclusion_of(:claim_window_id).in_array(valid_claim_window_ids) }
  end

  describe "#claim_windows_for_selection" do
    subject(:claim_windows_for_selection) { step.claim_windows_for_selection }

    before { create(:claim_window, :historic) }

    context "when there are no current or upcoming claim windows" do
      it "returns an empty array" do
        expect(claim_windows_for_selection).to eq([])
      end
    end

    context "when there is only a current claim window" do
      let!(:current_claim_window) { create(:claim_window, :current).decorate }

      it "returns an option for the current claim window" do
        expect(claim_windows_for_selection.count).to eq(1)
        current_claim_window_option = claim_windows_for_selection[0]
        expect(current_claim_window_option.id).to eq(current_claim_window.id)
        expect(current_claim_window_option.name).to eq(current_claim_window.name)
        expect(current_claim_window_option.phase_of_time).to eq("Current")
      end
    end

    context "when there is only an upcoming claim window" do
      let!(:upcoming_claim_window) { create(:claim_window, :upcoming).decorate }

      it "returns an option for the current claim window" do
        expect(claim_windows_for_selection.count).to eq(1)
        upcoming_claim_window_option = claim_windows_for_selection[0]
        expect(upcoming_claim_window_option.id).to eq(upcoming_claim_window.id)
        expect(upcoming_claim_window_option.name).to eq(upcoming_claim_window.name)
        expect(upcoming_claim_window_option.phase_of_time).to eq("Upcoming")
      end
    end

    context "when there is a current and upcoming claim window" do
      let!(:current_claim_window) { create(:claim_window, :current).decorate }
      let!(:upcoming_claim_window) { create(:claim_window, :upcoming).decorate }

      it "returns an option for the current claim window" do
        expect(claim_windows_for_selection.count).to eq(2)
        current_claim_window_option = claim_windows_for_selection[0]
        expect(current_claim_window_option.id).to eq(current_claim_window.id)
        expect(current_claim_window_option.name).to eq(current_claim_window.name)
        expect(current_claim_window_option.phase_of_time).to eq("Current")

        upcoming_claim_window_option = claim_windows_for_selection[1]
        expect(upcoming_claim_window_option.id).to eq(upcoming_claim_window.id)
        expect(upcoming_claim_window_option.name).to eq(upcoming_claim_window.name)
        expect(upcoming_claim_window_option.phase_of_time).to eq("Upcoming")
      end
    end
  end

  describe "#valid_claim_window_ids" do
    subject(:valid_claim_window_ids) { step.valid_claim_window_ids }

    before { create(:claim_window, :historic) }

    context "when there are no current or upcoming claim windows" do
      it "returns an empty array" do
        expect(valid_claim_window_ids).to eq([])
      end
    end

    context "when there is only a current claim window" do
      let!(:current_claim_window) { create(:claim_window, :current) }

      it "returns only the current claim window id" do
        expect(valid_claim_window_ids).to contain_exactly(current_claim_window.id)
      end
    end

    context "when there is only an upcoming claim window" do
      let!(:upcoming_claim_window) { create(:claim_window, :upcoming) }

      it "returns only the current claim window id" do
        expect(valid_claim_window_ids).to contain_exactly(upcoming_claim_window.id)
      end
    end

    context "when both a current and upcoming claim window exist" do
      let!(:current_claim_window) { create(:claim_window, :current) }
      let!(:upcoming_claim_window) { create(:claim_window, :upcoming) }

      it "returns the ids of both current and upcoming claim window" do
        expect(valid_claim_window_ids).to contain_exactly(
          current_claim_window.id, upcoming_claim_window.id
        )
      end
    end
  end
end
