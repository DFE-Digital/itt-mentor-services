require "rails_helper"

RSpec.describe "Sign In as a Claims User", service: :claims, type: :system do
  scenario "I sign in as a non-support user, with no organisation" do
    given_there_is_an_existing_user_for("Anne")
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    then_i_dont_get_redirected_to_support_organisations
    and_i_see_an_empty_schools_page

    and_i_visit_my_account_page
    then_i_see_user_details_for_anne
  end

  context "when the user is assigned to a school" do
    let!(:organisation) { create(:school, :claims, name: "Claims School") }

    scenario "I sign in as a school user and see my schools claims" do
      given_there_is_an_existing_user_for("Anne")
      and_the_user_is_part_of_an_organisation(organisation)
      when_i_visit_the_sign_in_path
      when_i_click_sign_in
      then_i_dont_get_redirected_to_support_organisations
      then_i_can_see_the_claims_school_claims_page
    end
  end

  scenario "I sign in as a support user" do
    given_a_school_has_been_onboarded_onto_the_claims_service(name: "Claims School")
    given_there_is_an_existing_support_user_for("Colin")
    when_i_visit_the_sign_in_path
    when_i_click_sign_in
    then_i_see_a_list_of_organisations

    and_i_visit_my_account_page
    then_i_see_user_details_for_colin
  end

  context "when response from dfe sign in is invalid" do
    scenario "I sign in as user" do
      invalid_dfe_sign_in_response
      when_i_visit_the_sign_in_path
      when_i_click_sign_in
      i_do_not_have_access_to_the_service
    end
  end

  context "when normal user tries to access support user page" do
    scenario "I sign in as a non-support user trying to access support user page" do
      given_there_is_an_existing_user_for("Anne")
      when_i_visit_the_sign_in_path
      when_i_click_sign_in
      visit_support_page
      i_do_not_have_access_to_support_page
    end
  end

  context "when dsi fails" do
    scenario "I try to sign in as support user" do
      when_dsi_fails
      when_i_visit_the_sign_in_path
      when_i_click_sign_in
      then_i_am_redirect_to_internal_server_error
    end
  end

  context "when I use a deep link without being logged in" do
    context "when I am a support user" do
      scenario "when I sign in as Colin I am redirected to my requested page" do
        given_there_is_an_existing_support_user_for("Colin")
        when_i_visit_my_account_page
        when_i_click_sign_in
        then_i_see_user_details_for_colin
      end
    end

    context "when I am not a support user" do
      let!(:organisation) { create(:school, :claims, name: "Claims School 1") }
      let(:another_organisation) { create(:school, :claims, name: "Claims School 2") }

      scenario "when I sign in as a school user I am redirected to my requested page" do
        given_there_is_an_existing_user_for("Anne")
        and_the_user_is_part_of_an_organisation(organisation)
        when_i_visit_my_account_page
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_sign_in
        then_i_see_user_details_for_anne
      end

      scenario "when I sign in as a multi-organisation user I am redirected to my organisations page" do
        given_there_is_an_existing_user_for("Anne")
        and_the_user_is_part_of_an_organisation(organisation)
        and_the_user_is_part_of_an_organisation(another_organisation)
        when_i_visit_my_account_page
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_sign_in
        then_i_see_user_details_for_anne
      end
    end

    context "when I revisit the root path after using a deep link to sign in" do
      context "when I sign in as a school user" do
        let!(:organisation) { create(:school, :claims, name: "Claims School") }

        scenario "I am redirected to the claims page for my school" do
          given_there_is_an_existing_user_for("Anne")
          and_the_user_is_part_of_an_organisation(organisation)
          when_i_visit_my_account_page
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_sign_in
          then_i_see_user_details_for_anne
          when_i_visit_the claims_root_path
          then_i_can_see_the_claims_school_claims_page
        end
      end

      context "when I sign in as a multi-organisation user" do
        let!(:organisation) { create(:school, :placements, name: "Claims School 1") }
        let!(:another_organisation) { create(:school, :placements, name: "Claims School 2") }

        scenario "I am redirected to the list of my organisations" do
          given_there_is_an_existing_user_for("Anne")
          and_the_user_is_part_of_an_organisation(organisation)
          and_the_user_is_part_of_an_organisation(another_organisation)
          when_i_visit_my_account_page
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_sign_in
          then_i_see_user_details_for_anne
          when_i_visit_the claims_root_path
          then_i_am_redirected_to_the_schools_page
        end
      end

      context "when I sign in as a support user" do
        scenario "I am redirected to the claims page for my school" do
          given_a_school_has_been_onboarded_onto_the_claims_service(name: "Claims School")
          given_there_is_an_existing_support_user_for("Colin")
          when_i_visit_my_account_page
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_sign_in
          then_i_see_user_details_for_colin
          when_i_visit_the claims_root_path
          then_i_see_a_list_of_organisations
        end
      end
    end
  end

  private

  def given_there_is_an_existing_user_for(user_name, with_dfe_sign_id: true)
    user = create(:claims_user, user_name.downcase.to_sym)
    user.update!(dfe_sign_in_uid: nil) unless with_dfe_sign_id
    user_exists_in_dfe_sign_in(user:)
  end

  def given_there_is_an_existing_support_user_for(user_name, with_dfe_sign_id: true)
    user = create(:claims_support_user, user_name.downcase.to_sym)
    user.update!(dfe_sign_in_uid: nil) unless with_dfe_sign_id
    user_exists_in_dfe_sign_in(user:)
  end

  def and_the_user_is_part_of_an_organisation(organisation)
    organisation.users << User.find_by(email: "anne_wilson@example.org")
  end

  def given_a_school_has_been_onboarded_onto_the_claims_service(name:)
    create(:claims_school, name:)
  end

  def given_there_is_an_existing_claims_user_with_a_school_for(user)
    user_exists_in_dfe_sign_in(user:)
    create(
      :user_membership,
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

  def and_i_click_on(text)
    click_on text
  end

  def and_i_visit_my_account_page
    visit account_path
  end
  alias_method :when_i_visit_my_account_page, :and_i_visit_my_account_page

  def when_i_visit_the(path)
    visit path
  end

  def then_i_see_user_details_for_anne
    expect(page).to have_current_path account_path
    page_has_user_content(
      first_name: "Anne",
      last_name: "Wilson",
      email: "anne_wilson@example.org",
    )
  end

  def then_i_see_user_details_for_colin
    expect(page).to have_current_path account_path
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

  def visit_support_page
    visit claims_support_schools_path
  end

  def i_do_not_have_access_to_support_page
    expect(page).to have_content "You cannot perform this action"
  end

  def then_i_am_redirect_to_internal_server_error
    expect(page).to have_content("Sorry, there’s a problem with the service")
  end

  def then_i_dont_get_redirected_to_support_organisations
    expect(page).to have_no_current_path claims_support_claims_path, ignore_query: true
  end

  def then_i_see_a_list_of_organisations
    expect(page).to have_current_path claims_support_schools_path, ignore_query: true
    expect(page).to have_content("Claims School")
  end

  def and_i_see_an_empty_schools_page
    expect(page).to have_current_path(claims_schools_path)
    expect(page).to have_content("Organisations")
    expect(find("#main-content")).not_to have_link
  end

  def then_i_can_see_the_claims_school_claims_page
    expect(page).to have_current_path(claims_school_claims_path(organisation))
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_current_path(sign_in_path)
  end

  def then_i_am_redirected_to_the_schools_page
    expect(page).to have_current_path(claims_schools_path)
  end
end
