require "rails_helper"

RSpec.describe "Non-support user with multiple organisations uses a deep link", service: :placements, type: :system do
  scenario do
    given_my_organisations_exist
    and_i_have_an_account
    when_i_visit_the_school_users_path
    then_i_am_redirected_to_the_sign_in_page

    when_i_click_on_sign_in_using_dfe_sign_in
    then_i_am_redirected_to_the_school_users_page
  end

  private

  def given_my_organisations_exist
    @school = create(:placements_school, name: "Hogwarts")
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
  end

  def and_i_have_an_account
    sign_in_placements_user(organisations: [@school, @provider], sign_in: false)
  end

  def when_i_visit_the_school_users_path
    visit placements_school_users_path(@school)
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Sign in to Manage school placements")
  end

  def when_i_click_on_sign_in_using_dfe_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_am_redirected_to_the_school_users_page
    expect(page).to have_title("Users - Manage school placements - GOV.UK")
    expect(page).to have_h1("Users")
    expect(page).to have_link("Add user", href: "/schools/#{@school.id}/users/new", class: "govuk-button")
  end
end
