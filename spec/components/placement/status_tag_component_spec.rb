require "rails_helper"

RSpec.describe Placement::StatusTagComponent, type: :component do
  subject(:component) do
    described_class.new(placement:, viewed_by_organisation:)
  end

  let(:placement) { create(:placement) }

  before do
    placement
  end

  context "when viewed by a school" do
    let(:viewed_by_organisation) { create(:placements_school) }

    context "when the placement does not have a provider" do
      it "renders the status as available" do
        render_inline(component)

        expect(page).to have_content("Available")
      end

      it "renders the status as green" do
        render_inline(component)

        expect(page).to have_css(".govuk-tag--green")
      end
    end

    context "when the placement has a provider" do
      let(:placement) { create(:placement, provider: create(:provider)) }

      it "renders the status as assigned to provider" do
        render_inline(component)

        expect(page).to have_content("Assigned to provider")
      end

      it "renders the status as blue" do
        render_inline(component)

        expect(page).to have_css(".govuk-tag--blue")
      end
    end
  end

  context "when viewed by a provider" do
    let(:viewed_by_organisation) { create(:placements_provider) }

    context "when the placement does not have a provider" do
      it "renders the status as available" do
        render_inline(component)

        expect(page).to have_content("Available")
      end

      it "renders the status as green" do
        render_inline(component)

        expect(page).to have_css(".govuk-tag--green")
      end
    end

    context "when the placement has a provider" do
      let(:placement) { create(:placement, provider: create(:placements_provider)) }

      it "renders the status as unavailable" do
        render_inline(component)

        expect(page).to have_content("Unavailable")
      end

      it "renders the status as red" do
        render_inline(component)

        expect(page).to have_css(".govuk-tag--red")
      end
    end

    context "when the placement is assigned to the organisation" do
      let(:placement) { create(:placement, provider: viewed_by_organisation) }

      it "renders the status as assigned to you" do
        render_inline(component)

        expect(page).to have_content("Assigned to you")
      end

      it "renders the status as blue" do
        render_inline(component)

        expect(page).to have_css(".govuk-tag--blue")
      end
    end
  end
end
