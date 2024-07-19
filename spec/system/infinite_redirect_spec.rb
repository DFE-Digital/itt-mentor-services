require "rails_helper"

RSpec.describe "Infinite redirect", service: :placements, type: :system do
  let!(:user) { create(:placements_support_user) }

  scenario "When the support users permissions are removed they aren't stuck in an infinite loop" do
    given_i_am_a_support_user
    when_i_view_all_organisations
    and_the_support_user_is_removed_as_a_support_user
    and_i_click_link("Organisations")
    then_i_no_longer_have_access_to_the_schools_details
    and_i_am_redirected_to_the_root_path
  end

  private

  def given_i_am_a_support_user
    sign_in_as user
  end

  def when_i_view_all_organisations
    visit placements_support_organisations_path
  end

  def and_the_support_user_is_removed_as_a_support_user
    user.update!(type: "Placements::User")
  end

  def and_i_click_link(text)
    click_link text
  end

  def then_i_no_longer_have_access_to_the_schools_details
    expect(page).to have_content("You cannot perform this action")
  end

  def and_i_am_redirected_to_the_root_path
    expect(page).to have_current_path(placements_root_path, ignore_query: true)
  end
end
