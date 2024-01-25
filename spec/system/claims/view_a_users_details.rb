require "rails_helper"

RSpec.describe "View a users details", type: :system do
  before do
    setup_school
    create_user
    attach_user_to_school
  end

  scenario "I sign in as a support user and invite a user to a school" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    verify_user_details
  end

  private

  def setup_school
    @school = create(:school, :claims, urn: "123456", name: "Test School")
  end

  def create_user
    @user = create(:user, :claims, first_name: "Barry", last_name: "Garlow", email: "barry.garlow@gmail.com")
  end

  def attach_user_to_school
    create(:membership, user: @user, organisation: @school)
  end

  def sign_in_as_support_user
    create(:claims_support_user, :colin)
    visit personas_path
    click_on "Sign In as Colin"
  end

  def visit_claims_support_school_users_page
    visit claims_support_school_user_path(id: @user.id, school_id: @school.id)
  end

  def verify_user_details
    expect(page).to have_content("Test School")
    expect(page).to have_content("First name Barry")
    expect(page).to have_content("Last name Garlow")
    expect(page).to have_content("Email barry.garlow@gmail.com")
  end
end
