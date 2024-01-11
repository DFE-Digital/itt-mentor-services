require "rails_helper"

describe OrganisationOnboardingForm, type: :model do
  describe "validations" do
    it { should validate_presence_of(:organisation_type) }
    it {
      should validate_inclusion_of(:organisation_type).in_array(
        described_class::ORGANISATION_TYPES,
      )
    }
  end

  describe "#options" do
    it "returns an array of organisation types as open structs" do
      expect(described_class.new.options).to match_array(
        [
          OpenStruct.new(
            id: described_class::ITT_PROVIDER,
            name: I18n.t(described_class::ITT_PROVIDER),
          ),
          OpenStruct.new(
            id: described_class::SCHOOL,
            name: I18n.t(described_class::SCHOOL),
          ),
        ],
      )
    end
  end

  describe "#onboarding_url" do
    context "when the organisation type is an ITT Provider" do
      it "returns the URL for onboarding a provider" do
        expect(
          described_class.new(
            organisation_type: described_class::ITT_PROVIDER,
          ).onboarding_url,
        ).to eq("/support/providers/new")
      end
    end

    context "when the organisation type is a school" do
      it "returns the URL for onboarding a school" do
        expect(
          described_class.new(
            organisation_type: described_class::SCHOOL,
          ).onboarding_url,
        ).to eq("/support/schools/new")
      end
    end

    context "when the organisation type isn't a valid type" do
      it "returns nil" do
        expect(
          described_class.new(
            organisation_type: "random",
          ).onboarding_url,
        ).to eq(nil)
      end
    end
  end
end
