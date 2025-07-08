require "rails_helper"

RSpec.describe Claims::ClaimWindowWarningBannerComponent, freeze: "1 July 2025", type: :component do
  subject(:component) { described_class.new }

  let(:claim_window) { create(:claim_window, :current, ends_on:) }

  before do
    claim_window
  end

  context "when there are > 30 days left in the claim window" do
    let(:ends_on) { Date.new(2025, 9, 1) }

    it "does not render the banner" do
      render_inline(component)

      expect(page).not_to have_css(".govuk-notification-banner")
      expect(page).not_to have_content("Important")
    end
  end

  context "when there are <= 30 days left in the claim window" do
    context "when there is more than 1 day left" do
      let(:ends_on) { Date.new(2025, 7, 8) }

      it "renders the banner" do
        render_inline(component)

        expect(page).to have_css(".govuk-notification-banner")
        expect(page).to have_content("Important")
        expect(page).to have_content("There are 7 days remaining to claim for ITT general mentor training before the claim window closes.")
      end
    end

    context "when there is 1 day left" do
      let(:ends_on) { Date.new(2025, 7, 2) }

      it "renders the banner" do
        render_inline(component)

        expect(page).to have_css(".govuk-notification-banner")
        expect(page).to have_content("Important")
        expect(page).to have_content("There is 1 day remaining to claim for ITT general mentor training before the claim window closes.")
      end
    end
  end

  context "when there are < 1 day left in the claim window" do
    let(:ends_on) { Date.new(2025, 7, 3) }

    context "when there is 23 hours left" do
      it "renders the banner" do
        Timecop.travel(Time.zone.local(2025, 7, 3, 0, 54, 50)) do
          render_inline(component)
          expect(page).to have_css(".govuk-notification-banner")
          expect(page).to have_content("Important")
          expect(page).to have_content("There are 23 hours and 5 minutes remaining to claim for ITT general mentor training before the claim window closes.")
        end
      end
    end

    context "when there is 1 hour left" do
      it "renders the banner" do
        Timecop.travel(Time.zone.local(2025, 7, 3, 22, 54, 50)) do
          render_inline(component)

          expect(page).to have_css(".govuk-notification-banner")
          expect(page).to have_content("Important")
          expect(page).to have_content("There is 1 hour and 5 minutes remaining to claim for ITT general mentor training before the claim window closes.")
        end
      end
    end

    context "when there is less than 1 hour left" do
      it "renders the banner" do
        Timecop.travel(Time.zone.local(2025, 7, 3, 23, 44, 50)) do
          render_inline(component)

          expect(page).to have_css(".govuk-notification-banner")
          expect(page).to have_content("Important")
          expect(page).to have_content("There are 15 minutes remaining to claim for ITT general mentor training before the claim window closes.")
        end
      end
    end
  end
end
