require "rails_helper"

RSpec.describe "Placements / Providers / View provider details", service: :placements, type: :system do
  let(:provider) do
    create(:placements_provider,
           name: "London Provider",
           urn: "123321",
           ukprn: "456654",
           email_address: "contact_london_provider@example.com",
           telephone: "01234 567890",
           website: "london_provider@example.com",
           address1: "London Provider",
           address2: "London",
           city: "City of London",
           postcode: "LN12 123")
  end

  scenario "User views their provider's details" do
    given_i_sign_in_as_patricia
    when_i_view_my_organisation_details_page
    then_i_see_the_details_for_my_provider
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_view_my_organisation_details_page
    visit placements_provider_path(provider)

    expect_organisation_details_to_be_selected_in_primary_navigation
  end

  def expect_organisation_details_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "page"
      expect(page).to have_link "Schools", current: "false"
    end
  end

  def then_i_see_the_details_for_my_provider
    expect(page.find(".govuk-heading-l")).to have_content("Organisation detail")
    expect(page).to have_content("Name")
    expect(page).to have_content("London Provider")
    expect(page).to have_content("UK provider reference number (UKPRN)")
    expect(page).to have_content("456654")
    expect(page).to have_content("Unique reference number (URN)")
    expect(page).to have_content("123321")
    # Contact details
    expect(page).to have_content("Email address")
    expect(page).to have_content("contact_london_provider@example.com")
    expect(page).to have_content("Telephone")
    expect(page).to have_content("01234 567890")
    expect(page).to have_content("Website")
    expect(page).to have_content("london_provider@example.com")
    expect(page).to have_content("Address")
    expect(page).to have_content(
      "London Provider London City of London LN12 123",
    )
  end
end
