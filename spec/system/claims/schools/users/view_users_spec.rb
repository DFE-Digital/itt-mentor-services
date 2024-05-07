require "rails_helper"

RSpec.describe "Invite and view a users details", type: :system do
  let(:school) { create(:claims_school, :claims, urn: "123456") }
  let(:anne) { create(:claims_user, :anne) }
  let(:another_school) { create(:claims_school, :claims) }

  before do
    setup_school_and_anne_membership
  end

  scenario "I sign in as a lead mentor user and invite a user to a school and view that users details" do
    sign_in_as_lead_mentor_user
    visit_claims_school_users_page
    when_i_click("Add user")
    fill_in_user_details
    when_i_click("Save user")
    show_user_details
  end

  private

  def setup_school_and_anne_membership
    create(:user_membership, user: anne, organisation: school)
    user_exists_in_dfe_sign_in(user: anne)
  end

  def sign_in_as_lead_mentor_user
    user_exists_in_dfe_sign_in(user: anne)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def visit_claims_school_users_page
    visit claims_school_users_path(school)
  end

  def fill_in_user_details
    fill_in "First name", with: "Barry"
    fill_in "Last name", with: "Garlow"
    fill_in "Email", with: "barry.garlow@eduction.gov.uk"
    click_on "Continue"
  end

  def show_user_details
    click_on "Barry Garlow"
    expect(page).to have_content("\nFirst nameBarry")
    expect(page).to have_content("\nLast nameGarlow")
    expect(page).to have_content("\nEmail addressbarry.garlow@eduction.gov.uk")
  end

  def when_i_click(button)
    click_on button
  end
end
