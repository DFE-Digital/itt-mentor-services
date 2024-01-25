require "rails_helper"

RSpec.describe "View users for school", type: :system do
  before do
    setup_school_and_anne_membership
  end

  scenario "I sign in as a support user and view a schools users index page" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    verify_users_list_for_school
  end

  private

  def setup_school_and_anne_membership
    @school = create(:school, :claims, urn: "123456")
    @anne_persona = create(:claims_user, :anne)
    create(:membership, user: @anne_persona, organisation: @school)
  end

  def sign_in_as_support_user
    create(:claims_support_user, :colin)
    visit personas_path
    click_on "Sign In as Colin"
  end

  def visit_claims_support_school_users_page
    visit claims_support_school_users_path(@school)
  end

  def verify_users_list_for_school
    expect(page).to have_content("Anne Wilson")
    expect(page).to have_content("anne_wilson@example.org")
  end
end
