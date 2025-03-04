require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::PrimaryPlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        selected_primary_subjects:,
        state:,
      )
    end
  end

  let(:attributes) { nil }
  let(:selected_primary_subjects) { Subject.none }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  let!(:primary_subject) { create(:subject, :primary, name: "Primary") }
  let!(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
  let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
  let(:secondary_subject) { create(:subject, :secondary, name: "Science") }

  before do
    primary_with_science
    secondary_subject
  end

  describe "attributes" do
    it "has no attributes" do
      expect(step.attributes).to eq({})
    end
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:selected_primary_subjects).to(:wizard) }
  end

  describe "variables" do
    context "when there are no selected primary subjects" do
      it "returns no variables related to any subjects" do
        expect { step.primary }.to raise_error(NoMethodError)
        expect { step.primary_with_english }.to raise_error(NoMethodError)
        expect { step.primary_with_science }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end

    context "when there are primary subejects" do
      let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }

      it "creates a variable method per selected primary subject" do
        expect(step.primary).to be_nil
        expect(step.primary_with_english).to be_nil
        expect { step.primary_with_science }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end
  end

  describe "validations" do
    context "when there are no selected primary subjects" do
      it "adds no errors to the step" do
        expect(step.valid?).to be(true)
      end
    end

    context "when there are selected primary subjects" do
      let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }
      let(:attributes) { { primary: nil, primary_with_english: "5" } }

      context "when an input is blank" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:primary]).to include("Primary can't be blank")
        end
      end

      context "when an input is not an integer" do
        let(:attributes) { { primary: "1.2", primary_with_english: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:primary]).to include("Primary must be a whole number")
        end
      end

      context "when an input is zero" do
        let(:attributes) { { primary: "0", primary_with_english: "5" } }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors[:primary]).to include("Primary must be greater than 0")
        end
      end

      context "when all inputs are integers greater than zero" do
        let(:attributes) { { primary: "1", primary_with_english: "5" } }

        it "returns valid" do
          expect(step.valid?).to be(true)
        end
      end
    end
  end

  describe "#subjects" do
    let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }

    it "returns the selected primary subjects" do
      expect(step.subjects).to contain_exactly(primary_subject, primary_with_english)
    end
  end

  describe "#assigned_variables" do
    subject(:assigned_variables) { step.assigned_variables }

    context "when there are no selected primary subjects" do
      it "returns an empty hash" do
        expect(assigned_variables).to eq({})
      end
    end

    context "when there are selected primary subjects" do
      let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }
      let(:attributes) { { primary: "2", primary_with_english: "5" } }

      it "returns a hash of assigned attributes, associated to the selected subjects" do
        expect(assigned_variables).to eq({ "primary" => "2", "primary_with_english" => "5" })
      end
    end
  end
end
