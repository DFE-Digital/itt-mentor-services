require "rails_helper"

RSpec.describe Placements::EditPlacementWizard::KeyStageStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::EditPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }

  let!(:school) { create(:placements_school, name: "School 1") }

  describe "attributes" do
    it { is_expected.to have_attributes(key_stage_id: nil) }
  end

  describe "validations" do
    let(:early_years) { create(:key_stage, name: "Early years") }
    let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let(:key_stage_5) { create(:key_stage, name: "Key stage 5") }
    let(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

    it { is_expected.to validate_presence_of(:key_stage_id) }
    it { is_expected.to validate_inclusion_of(:key_stage_id).in_array(Placements::KeyStage.ids) }
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

  describe "#key_stage" do
    subject(:key_stage) { step.key_stage }

    let(:early_years) { create(:key_stage, name: "Early years") }
    let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let(:key_stage_5) { create(:key_stage, name: "Key stage 5") }
    let!(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

    let(:attributes) { { key_stage_id: key_stage_1.id } }

    before do
      early_years
      key_stage_2
      key_stage_3
      key_stage_4
      key_stage_5
      mixed_key_stages
    end

    it "returns the key stage record associated with the set key stage ID" do
      expect(key_stage).to eq(key_stage_1)
    end
  end
end
