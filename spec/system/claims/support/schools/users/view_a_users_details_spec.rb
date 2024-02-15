require "rails_helper"

RSpec.describe "View a users details", type: :system do
  let(:user) { create(:claims_user, first_name: "Barry", last_name: "Garlow", email: "barry.garlow@gmail.com") }
  let(:school) { create(:school, :claims, urn: "123456", name: "Test School") }

  before do
    attach_user_to_school
  end

  scenario "I sign in as a support user and invite a user to a school" do
    sign_in_as_support_user
    visit_claims_support_school_users_page
    verify_user_details
  end

  private

  def attach_user_to_school
    create(:membership, user:, organisation: school)
  end

  def sign_in_as_support_user
    user = create(:claims_support_user, :colin)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def visit_claims_support_school_users_page
    visit claims_support_school_user_path(id: user.id, school_id: school.id)
  end

  def verify_user_details
    expect(page).to have_content("Test School")
    expect(page).to have_content("First name Barry")
    expect(page).to have_content("Last name Garlow")
    expect(page).to have_content("Email barry.garlow@gmail.com")
  end
end
