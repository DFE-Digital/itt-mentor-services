require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::KeyStageSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
      )
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "attributes" do
    it { is_expected.to have_attributes(key_stage_ids: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key_stage_ids) }
  end

  describe "#key_stages_for_selection" do
    subject(:key_stages_for_selection) { step.key_stages_for_selection }

    let!(:early_years) { create(:key_stage, name: "Early years") }
    let!(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let!(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let!(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let!(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let!(:key_stage_5) { create(:key_stage, name: "Key stage 5") }
    let(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

    before { mixed_key_stages }

    it "returns all key stages, expect for mixed key stages" do
      expect(key_stages_for_selection).to contain_exactly(
        early_years,
        key_stage_1,
        key_stage_2,
        key_stage_3,
        key_stage_4,
        key_stage_5,
      )
    end
  end

  describe "mixed_key_stage_option" do
    subject(:mixed_key_stage_option) { step.mixed_key_stage_option }

    let(:early_years) { create(:key_stage, name: "Early years") }
    let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let(:key_stage_5) { create(:key_stage, name: "Key stage 5") }
    let!(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

    before do
      early_years
      key_stage_1
      key_stage_2
      key_stage_3
      key_stage_4
      key_stage_5
    end

    it "returns the mixed key stage" do
      expect(mixed_key_stage_option).to eq(
        mixed_key_stages,
      )
    end
  end

  describe "#key_stage_ids" do
    subject(:key_stage_ids) { step.key_stage_ids }

    context "when key_stage_ids is blank" do
      it "returns an empty array" do
        expect(key_stage_ids).to eq([])
      end
    end

    context "when the key_stage_ids attribute contains a blank element" do
      let(:attributes) { { key_stage_ids: ["123", nil] } }

      it "removes the nil element from the key_stage_ids attribute" do
        expect(key_stage_ids).to contain_exactly("123")
      end
    end

    context "when the key_stage_ids attribute contains no blank elements" do
      let(:attributes) { { key_stage_ids: %w[123 456] } }

      it "returns the key_stage_ids attribute unchanged" do
        expect(key_stage_ids).to contain_exactly(
          "123",
          "456",
        )
      end
    end
  end
end
