require "rails_helper"

RSpec.describe "Placements user signs out", service: :placements, type: :system do
  scenario do
    given_a_school_exists
    and_i_am_signed_in
    then_i_see_a_sign_out_button

    when_i_click_sign_out
    then_i_see_the_sign_in_page

    when_i_visit_the_placements_page
    then_i_am_redirected_to_the_sign_in_page
  end

  private

  def given_a_school_exists
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(DfESignInUser).to receive(:logout_url).and_return("/auth/dfe/sign-out")
    # rubocop:enable RSpec/AnyInstance

    @school = create(:placements_school, name: "Hogwarts")
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def then_i_see_a_sign_out_button
    expect(page).to have_link("Sign out", href: "/auth/dfe/sign-out")
  end

  def when_i_click_sign_out
    click_on "Sign out"
  end

  def then_i_see_the_sign_in_page
    expect(page).to have_h1("Sign in to Manage school placements")
    expect(page).to have_element(:button, text: "Sign in using DfE Sign In", class: "govuk-button")
  end

  def when_i_visit_the_placements_page
    # The user is not authenticated and therefore there is no link to click
    visit placements_school_placements_path(@school)
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_h1("Sign in to Manage school placements")
    expect(page).to have_element(:button, text: "Sign in using DfE Sign In", class: "govuk-button")
  end
end
