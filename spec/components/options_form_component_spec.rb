require "rails_helper"

RSpec.describe OptionsFormComponent, type: :component do
  subject(:component) do
    described_class.new(
      model:,
      scope:,
      url: "",
      search_param: "School",
      records:,
      records_klass:,
      back_link: "",
    )
  end

  context "when model is a Claims::AddSchoolWizard::SchoolOptionsStep" do
    let(:records) { build_list(:placements_school, 2).map(&:decorate) }
    let(:records_klass) { "school" }
    let(:mock_wizard) { instance_double(Claims::AddSchoolWizard) }
    let(:model) do
      Claims::AddSchoolWizard::SchoolOptionsStep.new(
        wizard: mock_wizard,
        attributes: {},
      )
    end
    let(:scope) { :school }

    it "renders a form for selecting a school from a list" do
      render_inline(component)

      records.each do |record|
        expect(page).to have_field(record.name)
      end
    end
  end

  context "when model is a Placements::AddOrganisationWizard::OrganisationOptionsStep" do
    let(:records) { build_list(:placements_school, 2).map(&:decorate) }
    let(:records_klass) { "school" }
    let(:mock_wizard) { instance_double(Placements::AddOrganisationWizard) }
    let(:model) do
      Placements::AddOrganisationWizard::OrganisationOptionsStep.new(
        wizard: mock_wizard,
        attributes: {},
      )
    end
    let(:scope) { :school }

    it "renders a form for selecting a school from a list" do
      render_inline(component)

      records.each do |record|
        expect(page).to have_field(record.name)
      end
    end
  end

  describe "#form_description" do
    context "when records_klass is schools" do
      let(:mock_wizard) { instance_double(Claims::AddSchoolWizard) }
      let(:model) do
        Claims::AddSchoolWizard::SchoolOptionsStep.new(
          wizard: mock_wizard,
          attributes: {
            search_param: "school",
          },
        )
      end
      let(:scope) { :school }
      let(:records_klass) { "school" }

      context "with less than 15 schools" do
        let(:records) { build_list(:placements_school, 2).map(&:decorate) }

        it "returns" do
          render_inline(component)

          expect(component.form_description).to eq(
            "<a class=\"govuk-link govuk-link--no-visited-state\" href=\"\">" \
            "Change your search</a> if the school you’re looking for is not listed.",
          )
        end
      end

      context "with more than 15 schools" do
        let(:records) { build_list(:placements_school, 16).map(&:decorate) }

        it "returns" do
          render_inline(component)

          expect(component.form_description).to eq(
            "Showing the first 15 results. " \
            "<a class=\"govuk-link govuk-link--no-visited-state\" href=\"\">" \
            "Try narrowing down your search</a> " \
            "if the school you’re looking for is not listed.",
          )
        end
      end
    end
  end
end
