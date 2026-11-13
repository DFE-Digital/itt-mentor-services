require "rails_helper"

RSpec.describe "Microsoft outage banner", type: :system do
  shared_examples "a page with the Microsoft outage banner" do
    scenario "User visits the sign in page" do
      when_i_visit_the_sign_in_page
      then_i_see_the_microsoft_outage_banner
    end
  end

  context "when using the claims service", service: :claims do
    it_behaves_like "a page with the Microsoft outage banner"
  end

  context "when using the placements service", service: :placements do
    it_behaves_like "a page with the Microsoft outage banner"
  end

  private

  def when_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def then_i_see_the_microsoft_outage_banner
    expect(page).to have_important_banner(
      "We are aware that the global Microsoft outage is affecting your ability to log in.",
    )

    within(".govuk-notification-banner", text: "Microsoft outage") do
      expect(page).to have_css(".govuk-body", text: "We are actively monitoring this issue.")
    end
  end
end
