require "rails_helper"

RSpec.describe "Sign out as a Placements User", service: :placements, type: :system do
  let(:colin) { create(:placements_support_user, :colin) }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(DfESignInUser).to receive(:logout_url).and_return("/auth/dfe/sign-out")
    # rubocop:enable RSpec/AnyInstance
  end

  scenario "I sign out" do
    given_i_am_signed_in_as_a_support_user
    i_should_see_a_sign_out_button
    when_i_click_sign_out
    i_expect_to_be_on_sign_in_page
    when_i_visit_placements_schools_details_path
    then_i_am_unable_to_access_the_page
  end

  private

  def i_should_see_a_sign_out_button
    expect(page).to have_content("Sign out")
  end

  def when_i_click_sign_out
    click_on "Sign out"
  end

  def i_expect_to_be_on_sign_in_page
    expect(page).to have_content("Sign in to Manage school placements")
    expect(page).to have_content("Sign in using DfE Sign In")
  end

  def when_i_visit_placements_schools_details_path
    visit placements_organisations_path
  end

  def then_i_am_unable_to_access_the_page
    expect(page).to have_current_path(sign_in_path, ignore_query: true)
  end
end
