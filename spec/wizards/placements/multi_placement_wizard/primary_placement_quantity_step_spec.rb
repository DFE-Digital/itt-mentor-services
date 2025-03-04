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

  describe "attributes" do
    it "has no attributes" do
      expect(step.attributes).to eq({})
    end
  end

  describe "variables" do
    let(:primary_subject) { create(:subject, :primary, name: "Primary") }
    let(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
    let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
    let(:secondary_subject) { create(:subject, :secondary, name: "Science") }

    before do
      primary_subject
      primary_with_english
      primary_with_science
      secondary_subject
    end

    context "when there are no selected primary subjects" do
      it "returns no variables related to any subjects" do
        expect { step.primary }.to raise_error(NoMethodError)
        expect { step.primary_with_english }.to raise_error(NoMethodError)
        expect { step.primary_with_science }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end

    context "when there are primary subejects" do
      let(:primary_subject) { create(:subject, :primary, name: "Primary") }
      let(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
      let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
      let(:secondary_subject) { create(:subject, :secondary, name: "Science") }

      let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }

      before do
        primary_subject
        primary_with_english
        primary_with_science
        secondary_subject
      end

      it "creates a variable method per primary subject" do
        expect(step.primary).to be_nil
        expect(step.primary_with_english).to be_nil
        expect { step.primary_with_science }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end
  end

  describe "#subjects" do
    let!(:primary_subject) { create(:subject, :primary, name: "Primary") }
    let!(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
    let(:primary_with_science) { create(:subject, :primary, name: "Primary with science") }
    let(:secondary_subject) { create(:subject, :secondary, name: "Science") }
    let(:selected_primary_subjects) { Subject.where(id: [primary_subject.id, primary_with_english.id]) }

    before do
      primary_with_science
      secondary_subject
    end

    it "returns the selected primary subjects" do
      expect(step.subjects).to contain_exactly(primary_subject, primary_with_english)
    end
  end
end
