require "rails_helper"

RSpec.describe Placement::StatusTagComponent, type: :component do
  subject(:component) do
    described_class.new(placement:)
  end

  let(:placement) { create(:placement) }

  before do
    placement
  end

  context "when the placement does not have a provider" do
    it "renders the status as available" do
      render_inline(component)

      expect(page).to have_content("Available")
    end

    it "renders the status as turquoise" do
      render_inline(component)

      expect(page).to have_css(".govuk-tag--turquoise")
    end
  end

  context "when the placement has a provider" do
    let(:placement) { create(:placement, provider: create(:provider)) }

    it "renders the status as unavailable" do
      render_inline(component)

      expect(page).to have_content("Unavailable")
    end

    it "renders the status as orange" do
      render_inline(component)

      expect(page).to have_css(".govuk-tag--orange")
    end
  end
end
