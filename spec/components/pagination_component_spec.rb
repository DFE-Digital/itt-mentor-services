require "rails_helper"

RSpec.describe PaginationComponent, type: :component do
  it "renders the pagination content" do
    pagy = Pagy.new(count: 100, page: 2)
    render_inline described_class.new(pagy:)

    within "govuk-pagination__list" do
      expect(page).to have_text(1)
      expect(page).to have_text(2)
      expect(page).to have_link("Next")
    end
    expect(page).to have_text("Showing 26 to 50 of 100 results")
  end

  context "when we don't have more than 1 page of pagination" do
    it "doesn't render the pagination content" do
      pagy = Pagy.new(count: 25, page: 1)
      render_inline described_class.new(pagy:)

      within "govuk-pagination__list" do
        expect(page).to have_no_text(1)
        expect(page).to have_no_text(2)
        expect(page).to have_no_link("Next")
      end
      expect(page).to have_no_text("Showing 1 to 25 of 25 results")
    end
  end
end
