require "rails_helper"

RSpec.describe Placement::StatusTagComponent, type: :component do
  context "when the status is draft" do
    subject(:component) { described_class.new("draft") }

    it "renders a tag with the correct status" do
      render_inline(component)

      expect(page).to have_css(".govuk-tag.govuk-tag--grey", text: "Draft")
    end
  end

  context "when the status is published" do
    subject(:component) { described_class.new("published") }

    it "renders a tag with the correct status" do
      render_inline(component)

      expect(page).to have_css(".govuk-tag.govuk-tag--blue", text: "Published")
    end
  end
end
