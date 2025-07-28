require "rails_helper"

RSpec.describe Claims::ExportUsersWizard::ActivityLevelStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::ExportUsersWizard) }
  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(activity_selection: nil) }
  end

  describe "validations" do
    context "when activity_selection is blank" do
      let(:attributes) { { activity_selection: nil } }

      it "is not valid" do
        expect(step).not_to be_valid
        expect(step.errors[:activity_selection]).to include("Select which users to include")
      end
    end

    context "when activity_selection is not one of the accepted values" do
      let(:attributes) { { activity_selection: "unknown" } }

      it "is valid unless restricted by inclusion validation" do
        expect(step).not_to be_valid
      end
    end

    context "when activity_selection is 'all'" do
      let(:attributes) { { activity_selection: "all" } }

      it "is valid" do
        expect(step).to be_valid
      end
    end

    context "when activity_selection is 'active'" do
      let(:attributes) { { activity_selection: "active" } }

      it "is valid" do
        expect(step).to be_valid
      end
    end
  end
end
