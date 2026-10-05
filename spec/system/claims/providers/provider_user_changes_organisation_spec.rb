require "rails_helper"

RSpec.describe "Provider user changes organisation", service: :claims, type: :system do
  let!(:provider) { create(:claims_provider, name: "North Star SCITT") }
  let!(:other_provider) { create(:claims_provider, name: "Other Provider") }

  scenario "A user with multiple providers can change organisation" do
    given_i_am_signed_in_as_a_provider_user_with(providers: [provider, other_provider])
    when_i_click_on("North Star SCITT")
    when_i_click_on("Change organisation")
    then_i_see_both_providers
  end

  scenario "A user with a single provider cannot change organisation" do
    given_i_am_signed_in_as_a_provider_user_with(providers: [provider])
    then_i_do_not_see_the_change_organisation_link
  end

  private

  def given_i_am_signed_in_as_a_provider_user_with(providers:)
    sign_in_as(create(:claims_provider_user, :patricia, providers:))
  end

  def when_i_click_on(text)
    click_on text
  end

  def then_i_see_both_providers
    expect(page).to have_current_path(claims_providers_path)
    expect(page).to have_link("North Star SCITT")
    expect(page).to have_link("Other Provider")
  end

  def then_i_do_not_see_the_change_organisation_link
    expect(page).not_to have_link("Change organisation")
  end
end
