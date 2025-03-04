require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::SecondaryPlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        selected_secondary_subjects:,
        state:,
      )
    end
  end

  let(:attributes) { nil }
  let(:selected_secondary_subjects) { Subject.none }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  let(:primary_subject) { create(:subject, :primary, name: "Primary") }
  let!(:english) { create(:subject, :secondary, name: "English") }
  let!(:mathematics) { create(:subject, :secondary, name: "Mathematics") }
  let(:science) { create(:subject, :secondary, name: "Science") }

  before do
    primary_subject
    science
  end

  describe "attributes" do
    it "has no attributes" do
      expect(step.attributes).to eq({})
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:selected_secondary_subjects).to(:wizard) }
  end

  describe "variables" do
    context "when there are no selected secondary subjects" do
      it "returns no variables related to any subjects" do
        expect { step.primary }.to raise_error(NoMethodError)
        expect { step.english }.to raise_error(NoMethodError)
        expect { step.mathematics }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end

    context "when there are primary subejects" do
      let(:selected_secondary_subjects) { Subject.where(id: [english.id, mathematics.id]) }

      it "creates a variable method per selected secondary subject" do
        expect(step.english).to be_nil
        expect(step.mathematics).to be_nil
        expect { step.science }.to raise_error(NoMethodError)
        expect { step.primary }.to raise_error(NoMethodError)
      end
    end
  end

  describe "validations" do
    context "when there are no selected secondary subjects" do
      it "adds no errors to the step" do
        expect(step.valid?).to be(true)
      end
    end

    context "when there are selected secondary subjects" do
      let(:selected_secondary_subjects) { Subject.where(id: [english.id, mathematics.id]) }
      let(:attributes) { { english: nil, mathematics: "5" } }

      context "when an input is blank" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:english]).to include("English can't be blank")
        end
      end

      context "when an input is not an integer" do
        let(:attributes) { { english: "1.2", mathematics: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:english]).to include("English must be a whole number")
        end
      end

      context "when an input is zero" do
        let(:attributes) { { english: "0", mathematics: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:english]).to include("English must be greater than 0")
        end
      end

      context "when all inputs are integers greater than zero" do
        let(:attributes) { { english: "1", mathematics: "5" } }

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#subjects" do
    let(:selected_secondary_subjects) { Subject.where(id: [english.id, mathematics.id]) }

    it "returns the selected secondary subjects" do
      expect(step.subjects).to contain_exactly(english, mathematics)
    end
  end

  describe "#assigned_variables" do
    subject(:assigned_variables) { step.assigned_variables }

    context "when there are no selected secondary subjects" do
      it "returns an empty hash" do
        expect(assigned_variables).to eq({})
      end
    end

    context "when there are selected secondary subjects" do
      let(:selected_secondary_subjects) { Subject.where(id: [english.id, mathematics.id]) }
      let(:attributes) { { english: "2", mathematics: "5" } }

      it "returns a hash of assigned attributes, associated to the selected subjects" do
        expect(assigned_variables).to eq({ "english" => "2", "mathematics" => "5" })
      end
    end
  end
end
