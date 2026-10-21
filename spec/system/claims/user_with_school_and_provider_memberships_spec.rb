require "rails_helper"

RSpec.describe "User with school and provider memberships selects an organisation", service: :claims, type: :system do
  let!(:school) { create(:claims_school, name: "Hogwarts") }
  let!(:provider) { create(:claims_provider, name: "North Star SCITT") }
  let!(:other_school) { create(:claims_school, name: "Unconnected School") }
  let!(:other_provider) { create(:claims_provider, name: "Unconnected Provider") }

  scenario "User can switch between their school and their provider" do
    given_i_am_signed_in_as_a_school_and_provider_user
    then_i_see_only_my_school_and_provider
    when_i_click_on("North Star SCITT")
    then_i_see_the_provider_claims_page
    when_i_click_on("Change organisation")
    then_i_see_only_my_school_and_provider
    when_i_click_on("Hogwarts")
    then_i_see_the_school_claims_page
    when_i_click_on("Change organisation")
    then_i_see_only_my_school_and_provider
  end

  scenario "User cannot view a provider they have no membership for" do
    given_i_am_signed_in_as_a_school_and_provider_user
    expect { visit claims_provider_claims_path(other_provider) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "User cannot view a school they have no membership for" do
    given_i_am_signed_in_as_a_school_and_provider_user
    expect { visit claims_school_claims_path(other_school) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "A discarded provider record grants no provider access" do
    given_i_am_signed_in_as_a_school_and_provider_user(provider_user_attributes: { discarded_at: Time.current })
    visit claims_schools_path
    expect(page).not_to have_link("North Star SCITT")
    visit claims_provider_claims_path(provider)
    expect(page).not_to have_current_path(claims_provider_claims_path(provider))
    expect(page).not_to have_content("North Star SCITT")
  end

  scenario "A provider record without memberships grants no provider access" do
    given_i_am_signed_in_as_a_school_and_provider_user(provider_membership: false)
    visit claims_schools_path
    expect(page).not_to have_link("North Star SCITT")
    expect { visit claims_provider_claims_path(provider) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "Someone else's provider record grants no provider access" do
    school_user = create(:claims_user, :patricia)
    create(:user_membership, user: school_user, organisation: school)
    other_provider_user = create(:claims_provider_user, email: "other@example.com")
    create(:user_membership, user: other_provider_user, organisation: provider)
    sign_in_as(school_user)

    visit claims_providers_path

    expect(page).not_to have_link("North Star SCITT")
    visit claims_provider_claims_path(provider)
    expect(page).not_to have_current_path(claims_provider_claims_path(provider))
    expect(page).not_to have_content("North Star SCITT")
  end

  scenario "Provider memberships do not grant school access" do
    given_i_am_signed_in_as_a_school_and_provider_user(school_membership: false)
    visit claims_schools_path
    expect(page).not_to have_link("Hogwarts")
    expect { visit claims_school_claims_path(school) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  scenario "Support user sees only schools on the organisations page" do
    sign_in_as(create(:claims_support_user))
    visit claims_schools_path
    expect(page).to have_link("Hogwarts")
    expect(page).not_to have_link("North Star SCITT")
  end

  private

  def given_i_am_signed_in_as_a_school_and_provider_user(
    provider_user_attributes: {}, school_membership: true, provider_membership: true
  )
    school_user = create(:claims_user, :patricia)
    provider_user = create(
      :claims_provider_user,
      email: school_user.email,
      dfe_sign_in_uid: school_user.dfe_sign_in_uid,
      **provider_user_attributes,
    )
    create(:user_membership, user: school_user, organisation: school) if school_membership
    create(:user_membership, user: provider_user, organisation: provider) if provider_membership
    sign_in_as(school_user)
  end

  def when_i_click_on(text)
    click_on text
  end

  def then_i_see_only_my_school_and_provider
    expect(page).to have_current_path(claims_schools_path)
    expect(page).to have_css("h2", text: "Schools")
    expect(page).to have_css("h2", text: "Providers")
    expect(page).to have_link("Hogwarts")
    expect(page).to have_link("North Star SCITT")
    expect(page).not_to have_link("Unconnected School")
    expect(page).not_to have_link("Unconnected Provider")
  end

  def then_i_see_the_provider_claims_page
    expect(page).to have_current_path(claims_provider_claims_path(provider))
  end

  def then_i_see_the_school_claims_page
    expect(page).to have_current_path(claims_school_claims_path(school))
  end
end
