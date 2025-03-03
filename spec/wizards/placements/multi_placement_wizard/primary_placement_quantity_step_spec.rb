require "rails_helper"

RSpec.describe Placements::MultiPlacementWizard::PrimaryPlacementQuantityStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Placements::MultiPlacementWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        school:,
        selected_primary_subjects: primary_subjects,
        state:,
      )
    end
  end

  let(:attributes) { nil }
  let(:primary_subjects) { Subject.none }
  let!(:school) { create(:placements_school) }
  let(:state) { {} }

  describe "attributes" do
    it "has no attributes" do
      expect(step.attributes).to eq({})
    end
  end

  describe "variables" do
    before { create(:subject, :secondary, name: "Science") }

    context "when there are no primary subjects" do
      it "returns no variables related to any subjects" do
        expect { step.primary }.to raise_error(NoMethodError)
        expect { step.primary_with_english }.to raise_error(NoMethodError)
        expect { step.science }.to raise_error(NoMethodError)
      end
    end

    context "when there are primary subejects" do
      let(:primary_subject) { create(:subject, :primary, name: "Primary") }
      let(:primary_with_english) { create(:subject, :primary, name: "Primary with english") }
      let(:secondary_subject) { create(:subject, :secondary, name: "Science") }
      let(:primary_subjects) { Subject.primary }

      before do
        primary_subject
        primary_with_english
        secondary_subject
      end

      it "creates a variable method per primary subject" do
        expect(step.primary).to be_nil
        expect(step.primary_with_english).to be_nil
        expect { step.science }.to raise_error(NoMethodError)
      end
    end
  end
end
