require "rails_helper"

RSpec.describe Claims::AddSchoolWizard::SchoolStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) { instance_double(Claims::AddSchoolWizard) }

  let(:attributes) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, name: nil) }
  end

  describe "validations" do
    describe "#id_presence" do
      context "when id is not present" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:id]).to include(
            "Enter a school name, unique reference number (URN) or postcode",
          )
        end
      end
    end

    describe "school_already_onboarded?" do
      let(:attributes) { { id: school.id } }

      context "when the school is already onboarded onto the claims service" do
        let(:school) { create(:school, :claims) }

        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:id]).to include(
            "#{school.name} has already been added. Try another school",
          )
        end
      end
    end
  end

  describe "#autocomplete_path_value" do
    it "returns the URL for school suggestions" do
      expect(step.autocomplete_path_value).to eq("/api/school_suggestions")
    end
  end

  describe "#autocomplete_return_attributes_value" do
    it "returns the attributes returned by the school suggestions api" do
      expect(step.autocomplete_return_attributes_value).to match_array(%w[town postcode])
    end
  end

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "claims_#{mock_wizard.class.name.demodulize.underscore}_school_step",
      )
    end
  end

  describe "#school_name" do
    context "when school is nil" do
      it "returns nil" do
        expect(step.school_name).to be_nil
      end
    end

    context "when school is present" do
      let(:school) { create(:school, :claims) }
      let(:attributes) { { id: school.id } }

      it "returns the name of the school" do
        expect(step.school_name).to eq(school.name)
      end
    end
  end
end
