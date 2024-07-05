require "rails_helper"

RSpec.describe AutocompleteSelectFormComponent, type: :component do
  subject(:component) do
    described_class.new(
      model:,
      scope:,
      url:,
      data:,
      input:,
    )
  end

  context "with default attributes" do
    let(:model) { User.new }
    let(:scope) { :form }
    let(:url) { "" }
    let(:input) { {} }

    describe "data attribute validation" do
      context "when not given a autocomplete_path_value attribute" do
        let(:data) { {} }

        it "raises an error" do
          expect { component }.to raise_error(
            InvalidComponentError,
            "data[:autocomplete_path_value] can't be blank.",
          )
        end
      end

      context "when not given a autocomplete_return_attributes_value attribute" do
        let(:data) { { autocomplete_path_value: "#" } }

        it "raises an error" do
          expect { component }.to raise_error(
            InvalidComponentError,
            "data[:autocomplete_return_attributes_value] can't be blank.",
          )
        end
      end
    end

    context "when given sufficent data attributes" do
      let(:data) do
        { autocomplete_path_value: "#", autocomplete_return_attributes_value: [:value] }
      end

      it "returns an autocomplete select form" do
        render_inline(component)

        expect(page.find(".govuk-label")).to have_content("Label")
        expect(page.find(".govuk-caption-l")).to have_content("Caption")
        expect(page).to have_field("form-id-field")
        page.find("div[data-input-name='form[name]']")
      end
    end
  end

  context "with school onboarding attributes" do
    let(:model) { SchoolOnboardingForm.new }
    let(:scope) { :school }
    let(:url) { "" }
    let(:data) do
      {
        turbo: false,
        controller: "autocomplete",
        autocomplete_path_value: "/api/school_suggestions",
        autocomplete_return_attributes_value: %w[town postcode],
        input_name: "school[name]",
      }
    end
    let(:input) do
      {
        field_name: :id,
        value: nil,
        label: "Enter a school name, URN or postcode",
        caption: "Add organisation",
        previous_search: nil,
      }
    end

    it "returns an autocomplete select form for onboarding schools" do
      render_inline(component)

      page.find(
        "form[data-controller='autocomplete']" \
        "[data-autocomplete-path-value='/api/school_suggestions']" \
        "[data-autocomplete-return-attributes-value='[\"town\",\"postcode\"]']",
      )
      expect(page.find(".govuk-label")).to have_content("Enter a school name, URN or postcode")
      expect(page.find(".govuk-caption-l")).to have_content("Add organisation")
      expect(page).to have_field("school-id-field")
      page.find("div[data-input-name='school[name]']")
    end
  end
end
