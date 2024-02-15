require "rails_helper"

RSpec.describe ProviderOptionsFormComponent, type: :component do
  subject(:component) do
    described_class.new(
      model: ProviderOnboardingForm.new,
      url: "",
      search_param: "Provider",
      providers: providers.map(&:decorate),
      back_link: "",
    )
  end

  let(:providers) { build_list(:placements_provider, 2) }

  it "renders a form for selecting a school from a list" do
    render_inline(component)

    providers.each do |provider|
      expect(page).to have_field(provider.name)
    end
  end

  describe "#form_description" do
    context "with less than 15 schools" do
      it "returns" do
        render_inline(component)

        expect(component.form_description).to eq(
          "<a class=\"govuk-link govuk-link--no-visited-state\" href=\"\">" \
          "Change your search</a> if the provider you’re looking for is not listed.",
        )
      end
    end

    context "with more than 15 schools" do
      let(:providers) { build_list(:placements_provider, 16) }

      it "returns" do
        render_inline(component)

        expect(component.form_description).to eq(
          "Showing the first 15 results. " \
          "<a class=\"govuk-link govuk-link--no-visited-state\" href=\"\">" \
          "Try narrowing down your search</a> " \
          "if the provider you’re looking for is not listed.",
        )
      end
    end
  end
end
