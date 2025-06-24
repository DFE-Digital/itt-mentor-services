require "rails_helper"

RSpec.describe Claims::ClaimWindowWarningBannerComponent, type: :component do
  subject(:component) { described_class.new }

  let(:claim_window) { create(:claim_window, :current, ends_on:) }

  before do
    claim_window
    render_inline(component)
  end

  context "when there are > 30 days left in the claim window" do
    let(:ends_on) { 2.months.from_now }

    it "does not render the banner" do
      expect(page).not_to have_css(".govuk-notification-banner")
      expect(page).not_to have_content("Important")
    end
  end

  context "when there are <= 30 days left in the claim window" do
    context "when there is more than 1 day left" do
      let(:ends_on) { 1.week.from_now }

      it "renders the banner" do
        expect(page).to have_css(".govuk-notification-banner")
        expect(page).to have_content("Important")
        expect(page).to have_content("There are 7 days remaining to claim for ITT general mentor training before the claim window closes.")
      end
    end

    context "when there is 1 day left" do
      let(:ends_on) { 1.day.from_now }

      it "renders the banner" do
        expect(page).to have_css(".govuk-notification-banner")
        expect(page).to have_content("Important")
        expect(page).to have_content("There is 1 day remaining to claim for ITT general mentor training before the claim window closes.")
      end
    end
  end
end
