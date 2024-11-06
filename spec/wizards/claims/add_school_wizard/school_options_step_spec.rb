require "rails_helper"

RSpec.describe Claims::AddSchoolWizard::SchoolOptionsStep, type: :model do
  subject(:step) { described_class.new(wizard: mock_wizard, attributes:) }

  let(:mock_wizard) do
    instance_double(Claims::AddSchoolWizard).tap do |mock_wizard|
      allow(mock_wizard).to receive_messages(
        steps: { school: school_step },
      )
    end
  end

  let(:school_step) do
    instance_double(Claims::AddSchoolWizard::SchoolStep).tap do |school_step|
      allow(school_step).to receive(:id).and_return(school_search_name)
    end
  end

  let(:attributes) { nil }
  let(:school_search_name) { nil }

  describe "attributes" do
    it { is_expected.to have_attributes(id: nil, search_param: nil) }
  end

  describe "validations" do
    describe "#id_presence" do
      context "when id is not present" do
        it "returns invalid" do
          expect(step.valid?).to be(false)
          expect(step.errors.messages[:id]).to include(
            "Select a school",
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

  describe "#scope" do
    it "returns a form scope for the class" do
      expect(step.scope).to eq(
        "claims_#{mock_wizard.class.name.demodulize.underscore}_school_options_step",
      )
    end
  end

  describe "schools" do
    let(:school_search_name) { "York" }
    let(:school_type) { "school" }
    let(:school_model) { School }
    let(:is_provider) { false }

    let(:liverpool_school) { create(:school, name: "Liverpool school") }
    let(:york_provider) { create(:provider, name: "York provider") }
    let!(:yorkshire_school) { create(:school, name: "Yorkshire school") }
    let!(:york_school) { create(:school, name: "York school") }

    before do
      liverpool_school
      york_provider
    end

    it "returns a list of schools with names similar to the search params" do
      expect(step.schools).to contain_exactly(york_school, yorkshire_school)
    end
  end

  describe "search_params" do
    let(:school_search_name) { "School" }

    context "when the search_param attribute is present" do
      let(:attributes) { { search_param: "Primary" } }

      it "returns the search param" do
        expect(step.search_params).to eq("Primary")
      end
    end

    context "when the search_param attribute is not present" do
      it "returns the school search name" do
        expect(step.search_params).to eq("School")
      end
    end
  end
end
