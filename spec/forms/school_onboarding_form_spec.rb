require "rails_helper"

describe SchoolOnboardingForm, type: :model do
  describe "validations" do
    it { should validate_presence_of(:service) }
    it { should validate_inclusion_of(:service).in_array(%i[placements claims]) }

    context "when urn is not present" do
      it "returns invalid" do
        form = described_class.new(urn: nil, service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:urn]).to include("Enter a school name, URN or postcode")
      end
    end

    context "when urn is not present and javascript is disabled" do
      it "returns invalid" do
        form = described_class.new(urn: nil, service: :placements, javascript_disabled: true)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:urn]).to include("Select a school")
      end
    end

    context "when given a urn not associated with a school" do
      it "returns invalid" do
        form = described_class.new(urn: "random", service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:urn]).to include("Enter a school name, URN or postcode")
      end
    end

    context "when given a urn for a school already onboarded onto the given service" do
      it "returns invalid" do
        school = create(:school, :placements)
        form = described_class.new(urn: school.urn, service: :placements)
        expect(form.valid?).to eq(false)
        expect(form.errors.messages[:urn]).to include("#{school.name} has already been added. Try another school")
      end
    end

    context "when given a urn for a school not onboarded onto the given service" do
      it "returns valid" do
        school = create(:school, :claims)
        form = described_class.new(urn: school.urn, service: :placements)
        expect(form.valid?).to eq(true)
      end
    end
  end

  describe "#school" do
    context "when given the urn of an existing school" do
      it "returns the school associated with that urn" do
        school = create(:school)
        expect(described_class.new(urn: school.urn).school).to eq(school)
      end
    end

    context "when given a urn not associated with a school" do
      it "returns nil" do
        expect(described_class.new(urn: "random").school).to eq(nil)
      end
    end
  end

  describe "onboard" do
    it "enables the boolean flag for the given service" do
      school = create(:school)
      onboarding = expect do
        described_class.new(urn: school.urn, service: :placements).onboard
        school.reload
      end
      onboarding.to change(school, :placements).from(false).to(true)
    end
  end
end
