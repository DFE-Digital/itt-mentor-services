require "rails_helper"

RSpec.describe "Sign In as a Claims User", type: :system, service: :claims do
  let(:anne) { create(:claims_user, :anne) }
  let(:patricia) { create(:claims_user, :patricia) }
  let(:mary) { create(:claims_user, :mary) }
  let(:colin) { create(:claims_support_user, :colin) }

  scenario "I sign in as user Anne" do
    given_there_is_an_existing_claims_user_with_a_school_for(anne)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    and_i_visit_my_account_page
    then_i_see_user_details_for_anne
  end

  scenario "I sign in as user Patricia" do
    given_there_is_an_existing_claims_user_with_a_school_for(patricia)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    and_i_visit_my_account_page
    then_i_see_user_details_for_patricia
  end

  scenario "I sign in as user Mary" do
    given_there_is_an_existing_claims_user_with_a_school_for(mary)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    and_i_visit_my_account_page
    then_i_see_user_details_for_mary
  end

  scenario "I sign in as user colin" do
    given_there_is_an_existing_claims_user_with_a_school_for(colin)
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    and_i_visit_my_account_page
    then_i_see_user_details_for_colin
  end

  context "when response from dfe sign in is invalid" do
    scenario "I sign in as user colin" do
      invalid_dfe_sign_in_response
      when_i_visit_the_sign_in_path
      when_i_click_sign_in
      i_do_not_have_access_to_the_service
    end
  end
end

private

def given_there_is_an_existing_claims_user_with_a_school_for(user)
  user_exists_in_dfe_sign_in(user:)
  create(
    :membership,
    user:,
    organisation: create(:school, :claims),
  )
end

def when_i_visit_the_sign_in_path
  visit sign_in_path
end

def when_i_click_sign_in
  click_on "Sign in using DfE Sign In"
end

def and_i_visit_my_account_page
  visit account_path
end

def then_i_see_user_details_for_anne
  page_has_user_content(
    first_name: "Anne",
    last_name: "Wilson",
    email: "anne_wilson@example.org",
  )
end

def then_i_see_user_details_for_patricia
  page_has_user_content(
    first_name: "Patricia",
    last_name: "Adebayo",
    email: "patricia@example.com",
  )
end

def then_i_see_user_details_for_mary
  page_has_user_content(
    first_name: "Mary",
    last_name: "Lawson",
    email: "mary@example.com",
  )
end

def then_i_see_user_details_for_colin
  page_has_user_content(
    first_name: "Colin",
    last_name: "Chapman",
    email: "colin.chapman@education.gov.uk",
  )
end

def page_has_user_content(first_name:, last_name:, email:)
  expect(page).to have_content(first_name)
  expect(page).to have_content(last_name)
  expect(page).to have_content(email)
end

def i_do_not_have_access_to_the_service
  expect(page).to have_content("You do not have access to this service")
end
