require "rails_helper"

RSpec.describe Claims::AddSchoolWizard::SchoolSelectionStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::AddSchoolWizard) }

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil) }
  end

  describe "#school" do
    let(:attributes) { { id: school.id } }
    let(:school) { create(:school) }

    it "returns the school record" do
      expect(step.school).to eq(school)
    end
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "claims_#{mock_wizard.class.name.demodulize.underscore}_school_selection_step",
      )
    end
  end
end
