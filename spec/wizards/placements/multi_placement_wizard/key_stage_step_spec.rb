require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::KeyStageStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive(:school).and_return(school)
    end
  end

  let(:attributes) { nil }
  let!(:school) { create(:placements_school) }

  describe "attributes" do
    it { is_expected.to have_attributes(key_stages: []) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:key_stages) }
  end

  describe "#key_stages_for_selection" do
    subject(:key_stages_for_selection) { step.key_stages_for_selection }

    let!(:early_years) { create(:key_stage, name: "Early years") }
    let!(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let!(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let!(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let!(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let!(:key_stage_5) { create(:key_stage, name: "Key stage 5") }

    it "returns the list of key stages ordered by name" do
      expect(key_stages_for_selection).to eq(
        [
          early_years,
          key_stage_1,
          key_stage_2,
          key_stage_3,
          key_stage_4,
          key_stage_5,
        ],
      )
    end
  end

  describe "#key_stages" do
    subject(:key_stages) { step.key_stages }

    let(:early_years) { create(:key_stage, name: "Early years") }
    let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
    let!(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
    let(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
    let(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
    let!(:key_stage_5) { create(:key_stage, name: "Key stage 5") }

    before do
      early_years
      key_stage_1
      key_stage_3
      key_stage_4
    end

    context "when key_stages is blank" do
      it "returns an empty array" do
        expect(key_stages).to eq([])
      end
    end

    context "when the key_stages attribute contains a blank element" do
      let(:attributes) { { key_stages: [key_stage_2.id, nil] } }

      it "removes the nil element from the key_stages attribute" do
        expect(key_stages).to contain_exactly(key_stage_2.id)
      end
    end

    context "when the key_stages attribute contains no blank elements" do
      let(:attributes) { { key_stages: [key_stage_2.id, key_stage_5.id] } }

      it "returns the phases attribute unchanged" do
        expect(key_stages).to contain_exactly(
          key_stage_2.id, key_stage_5.id
        )
      end
    end
  end
end
