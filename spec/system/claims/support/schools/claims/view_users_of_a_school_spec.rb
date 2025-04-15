require "rails_helper"

RSpec.describe "Claims support user view users for school", service: :claims, type: :system do
  scenario do
    given_a_school_exists_with_claims_users
    and_i_am_signed_in_as_a_support_user

    when_i_nagivate_to_organisations
    then_i_see_the_organisations_page

    when_i_click_on_shelbyville_elementary
    and_i_click_on_users

    then_i_see_the_claim_users_page
  end

  private

  def given_a_school_exists_with_claims_users
    @user_anne = create(:claims_user, first_name: "Anne", last_name: "Wilson", email: "anne_wilson@education.gov.uk")
    @support_user = create(:claims_support_user)

    @shelbyville_school = create(
      :claims_school,
      name: "Shelbyville Elementary",
      users: [@user_anne],
    )
  end

  def and_i_am_signed_in_as_a_support_user
    sign_in_claims_support_user
  end

  def when_i_nagivate_to_organisations
    within(".app-primary-navigation") do
      click_on "Organisations"
    end
  end

  def when_i_click_on_shelbyville_elementary
    click_on "Shelbyville Elementary"
  end

  def and_i_click_on_users
    within secondary_navigation do
      click_on "Users"
    end
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_h1("Organisations (1)")
    expect(page).to have_link(
      text: "Add organisation",
      class: "govuk-button",
    )
    expect(page).to have_element(
      :label,
      text: "Search by organisation name or postcode",
      class: "govuk-label govuk-label--m",
    )
    expect(page).to have_link("Shelbyville Elementary", href: "/support/schools/#{@shelbyville_school.id}")
  end

  def then_i_see_the_claim_users_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(secondary_navigation).to have_current_item("Users")
    expect(page).to have_h1("Shelbyville Elementary")
    expect(page).to have_h2("Users")
    expect(page).to have_table_row({
      "Name" => "Anne Wilson",
      "Email" => "anne_wilson@education.gov.uk",
    })
  end
end
