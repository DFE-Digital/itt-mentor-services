require "rails_helper"

RSpec.describe "Non-support user visits root path after using a deep link", service: :placements, type: :system do
  scenario do
    given_my_provider_exists
    and_i_have_an_account
    when_i_visit_the_sign_out_path
    then_i_am_redirected_to_the_sign_in_page

    when_i_click_on_sign_in_using_dfe_sign_in
    then_i_am_redirected_to_the_find_page

    when_i_visit_the_placements_root_path
    and_i_click_on_start_now
    then_i_see_the_find_page
  end

  private

  def given_my_provider_exists
    @provider = create(:placements_provider, name: "Aes Sedai Trust")
  end

  def and_i_have_an_account
    sign_in_placements_user(organisations: [@provider], sign_in: false)
  end

  def when_i_visit_the_sign_out_path
    visit sign_out_path
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Sign in to Manage school placements")
  end

  def when_i_click_on_sign_in_using_dfe_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_am_redirected_to_the_find_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(page).to have_element(:span, text: "Aes Sedai Trust", class: "govuk-heading-s")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
  end
  alias_method :then_i_see_the_find_page, :then_i_am_redirected_to_the_find_page

  def when_i_visit_the_placements_root_path
    visit placements_root_path
  end

  def and_i_click_on_start_now
    click_on "Start now"
  end
end
