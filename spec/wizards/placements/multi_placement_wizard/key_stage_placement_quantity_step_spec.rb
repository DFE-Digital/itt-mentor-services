require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::KeyStagePlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        selected_key_stages:,
        state:,
      )
    end
  end

  let(:attributes) { nil }
  let(:selected_key_stages) { Placements::KeyStage.none }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  let!(:early_years) { create(:key_stage, name: "Early years") }
  let(:key_stage_1) { create(:key_stage, name: "Key stage 1") }
  let!(:key_stage_2) { create(:key_stage, name: "Key stage 2") }
  let(:key_stage_3) { create(:key_stage, name: "Key stage 3") }
  let(:key_stage_4) { create(:key_stage, name: "Key stage 4") }
  let(:key_stage_5) { create(:key_stage, name: "Key stage 5") }
  let(:mixed_key_stages) { create(:key_stage, name: "Mixed key stages") }

  before do
    key_stage_1
    key_stage_3
    key_stage_4
    key_stage_5
    mixed_key_stages
  end

  describe "attributes" do
    it "has no attributes" do
      expect(step.attributes).to eq({})
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:selected_key_stages).to(:wizard) }
  end

  describe "variables" do
    context "when there are no selected key stages" do
      it "returns no variables related to any key stages" do
        expect { step.early_years }.to raise_error(NoMethodError)
        expect { step.key_stage_1 }.to raise_error(NoMethodError)
        expect { step.key_stage_2 }.to raise_error(NoMethodError)
        expect { step.key_stage_3 }.to raise_error(NoMethodError)
        expect { step.key_stage_4 }.to raise_error(NoMethodError)
        expect { step.key_stage_5 }.to raise_error(NoMethodError)
        expect { step.mixed_key_stages }.to raise_error(NoMethodError)
      end
    end

    context "when there are key stages" do
      let(:selected_key_stages) { Placements::KeyStage.where(id: [early_years.id, key_stage_2.id]) }

      it "creates a variable method per selected key stage" do
        expect(step.early_years).to be_nil
        expect { step.key_stage_1 }.to raise_error(NoMethodError)
        expect(step.key_stage_2).to be_nil
        expect { step.key_stage_3 }.to raise_error(NoMethodError)
        expect { step.key_stage_4 }.to raise_error(NoMethodError)
        expect { step.key_stage_5 }.to raise_error(NoMethodError)
        expect { step.mixed_key_stages }.to raise_error(NoMethodError)
      end
    end
  end

  describe "validations" do
    context "when there are no selected key stages" do
      it "adds no errors to the step" do
        expect(step.valid?).to be(true)
      end
    end

    context "when there are selected key stages" do
      let(:selected_key_stages) { Placements::KeyStage.where(id: [early_years.id, key_stage_2.id]) }
      let(:attributes) { { early_years: nil, key_stage_2: "5" } }

      context "when an input is blank" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:early_years]).to include("Early years can't be blank")
        end
      end

      context "when an input is not an integer" do
        let(:attributes) { { early_years: "1.2", key_stage_2: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:early_years]).to include("Early years must be a whole number")
        end
      end

      context "when an input is zero" do
        let(:attributes) { { early_years: "0", key_stage_2: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:early_years]).to include("Early years must be greater than 0")
        end
      end

      context "when all inputs are integers greater than zero" do
        let(:attributes) { { early_years: "1", key_stage_2: "5" } }

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#key_stages" do
    let(:selected_key_stages) { Placements::KeyStage.where(id: [early_years.id, key_stage_2.id]) }

    it "returns the selected key stages" do
      expect(step.key_stages).to contain_exactly(early_years, key_stage_2)
    end
  end

  describe "#assigned_variables" do
    subject(:assigned_variables) { step.assigned_variables }

    context "when there are no selected key stages" do
      it "returns an empty hash" do
        expect(assigned_variables).to eq({})
      end
    end

    context "when there are selected key stages" do
      let(:selected_key_stages) { Placements::KeyStage.where(id: [early_years.id, key_stage_2.id]) }
      let(:attributes) { { early_years: "1", key_stage_2: "5" } }

      it "returns a hash of assigned attributes, associated to the selected key stages" do
        expect(assigned_variables).to eq({ "early_years" => "1", "key_stage_2" => "5" })
      end
    end
  end
end
