require "rails_helper"

RSpec.describe "Support user receives invalid DfE response", service: :placements, type: :system do
  scenario do
    given_i_visit_the_service
    and_i_click_on_start_now
    then_i_see_the_sign_in_page

    when_i_click_on_sign_in_using_dfe_sign_in
    then_i_do_not_have_access_to_the_service
  end

  private

  def given_i_visit_the_service
    visit placements_root_path
  end

  def and_i_click_on_start_now
    click_on "Start now"
  end

  def then_i_see_the_sign_in_page
    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Sign in to Manage school placements")
  end

  def when_i_click_on_sign_in_using_dfe_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_do_not_have_access_to_the_service
    expect(page).to have_important_banner("You do not have access to this service")
  end
end
