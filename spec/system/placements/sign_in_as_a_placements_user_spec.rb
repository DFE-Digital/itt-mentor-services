require "rails_helper"

RSpec.describe "Sign In as a Placements User", service: :placements, type: :system do
  scenario "I sign in as a non-support user, with no organisation" do
    given_i_am_signed_in_as_a_placements_user
    then_i_dont_get_redirected_to_support_organisations
    and_i_see_an_empty_organsations_page
  end

  context "when the user is assigned to a school" do
    let!(:organisation) { create(:school, :placements, name: "Placement School") }

    scenario "I sign in as a school user and see my schools placements" do
      given_i_am_signed_in_as_a_placements_user(organisations: [organisation])
      then_i_dont_get_redirected_to_support_organisations
      then_i_can_see_the_placements_school_placements_page
    end
  end

  context "when the user is assigned to a provider" do
    let!(:organisation) { create(:provider, :placements, name: "Provider") }

    scenario "I sign in as a provider user and see the placements list page" do
      given_i_am_signed_in_as_a_placements_user(organisations: [organisation])
      then_i_dont_get_redirected_to_support_organisations
      then_i_can_see_the_placements_page
    end
  end

  context "when the user is assigned to multiple organisations" do
    let!(:organisation) { create(:school, :placements, name: "Placement School") }
    let(:provider_organisation) { create(:provider, :placements, name: "Provider") }

    scenario "I sign in as a multi organisation user and see a list of my organisations" do
      given_i_am_signed_in_as_a_placements_user(organisations: [organisation, provider_organisation])
      then_i_dont_get_redirected_to_support_organisations
      then_i_am_redirected_to_the_organisations_page
    end
  end

  scenario "I sign in as a support user" do
    given_there_are_placement_organisations
    given_i_am_signed_in_as_a_placements_support_user
    then_i_see_a_list_of_organisations
  end

  context "when response from dfe sign in is invalid" do
    scenario "I sign in as user colin" do
      invalid_dfe_sign_in_response
      when_i_visit_the(sign_in_path)
      when_i_click_on("Sign in using DfE Sign In")
      i_do_not_have_access_to_the_service
    end
  end

  context "when normal user tries to access support user page" do
    scenario "I sign in as user mary trying to access support user page" do
      given_i_am_signed_in_as_a_placements_user
      visit_support_page
      i_do_not_have_access_to_support_page
    end
  end

  context "when dsi fails" do
    scenario "I try to sign in as support user" do
      when_dsi_fails
      when_i_visit_the(sign_in_path)
      when_i_click_on("Sign in using DfE Sign In")
      then_i_am_redirect_to_internal_server_error
    end
  end

  context "when the user has both a support and non-support account" do
    scenario "I sign in as user colin and accesses the support user page" do
      given_there_are_placement_organisations
      given_i_am_signed_in_as_a_placements_user
      and_the_placements_user_is_also_a_support_user
      when_i_visit_the(sign_in_path)

      then_i_see_a_list_of_organisations
    end
  end

  context "when the user does not have a DfE ID" do
    context "when the user is not a support user" do
      scenario "I sign in as user Anne, using my email address" do
        given_i_am_signed_in_as_a_placements_user(with_dfe_sign_id: false)
        then_i_dont_get_redirected_to_support_organisations
      end
    end

    context "when the user is a support user" do
      scenario "I sign in as support user Colin, using my email address" do
        given_there_are_placement_organisations
        given_i_am_signed_in_as_a_placements_support_user(with_dfe_sign_id: false)
        then_i_see_a_list_of_organisations
      end
    end
  end

  context "when I use a deep link without being logged in" do
    context "when I am a support user" do
      scenario "when I sign in as Colin I am redirected to my requested page" do
        given_i_am_signed_in_as_a_placements_support_user(sign_in: false)
        when_i_visit_the_support_users_path
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_on("Sign in using DfE Sign In")
        then_i_am_redirected_to_the_support_users_page
      end
    end

    context "when I am not a support user" do
      let!(:organisation) { create(:school, :placements, name: "Deep Link Placement School") }
      let(:provider_organisation) { create(:provider, :placements, name: "Provider") }

      scenario "when I sign in as a school user I am redirected to my requested page" do
        given_i_am_signed_in_as_a_placements_user(organisations: [organisation], sign_in: false)
        when_i_visit_the_school_users_path(organisation)
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_on("Sign in using DfE Sign In")
        then_i_am_redirected_to_the_school_users_page(organisation)
      end

      scenario "when I sign in as a multi-organisation user I am redirected to my organisations page" do
        given_i_am_signed_in_as_a_placements_user(
          organisations: [organisation, provider_organisation],
          sign_in: false,
        )
        when_i_visit_the_school_users_path(organisation)
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_on("Sign in using DfE Sign In")
        then_i_am_redirected_to_the_school_users_page(organisation)
      end
    end

    context "when the deep link is the sign in path" do
      let!(:organisation) { create(:school, :placements, name: "Deep Link Placement School") }

      scenario "when I sign in as a school user I am redirect to the placements page" do
        given_i_am_signed_in_as_a_placements_user(organisations: [organisation], sign_in: false)
        when_i_visit_the(sign_in_path)
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_on("Sign in using DfE Sign In")
        then_i_can_see_the_placements_school_placements_page
      end
    end

    context "when the deep link is the sign out path" do
      let!(:organisation) { create(:school, :placements, name: "Deep Link Placement School") }

      scenario "when I sign in as a school user I am redirect to the placements page" do
        given_i_am_signed_in_as_a_placements_user(organisations: [organisation], sign_in: false)
        when_i_visit_the(sign_out_path)
        then_i_am_redirected_to_the_sign_in_page
        when_i_click_on("Sign in using DfE Sign In")
        then_i_can_see_the_placements_school_placements_page
      end
    end

    context "when I revisit the root path after using a deep link to sign in" do
      let!(:organisation) { create(:school, :placements, name: "Deep Link Placement School") }

      context "when I sign in as a school user" do
        scenario "I am redirected to the placements page for my school" do
          given_i_am_signed_in_as_a_placements_user(organisations: [organisation], sign_in: false)
          when_i_visit_the_school_users_path(organisation)
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_on("Sign in using DfE Sign In")
          then_i_am_redirected_to_the_school_users_page(organisation)
          when_i_visit_the placements_root_path
          and_i_click_on "Start now"
          then_i_can_see_the_placements_school_placements_page
        end
      end

      context "when I sign in as a provider user" do
        let!(:organisation) { create(:provider, :placements, name: "Provider") }

        scenario "I am redirected to the placements page for my school" do
          given_i_am_signed_in_as_a_placements_user(organisations: [organisation], sign_in: false)
          when_i_visit_the_provider_users_path(organisation)
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_on("Sign in using DfE Sign In")
          then_i_am_redirected_to_the_provider_users_page(organisation)
          when_i_visit_the placements_root_path
          and_i_click_on "Start now"
          then_i_can_see_the_placements_page
        end
      end

      context "when I sign in as a multi-organisation user" do
        let!(:organisation) { create(:school, :placements, name: "Deep Link Placement School") }
        let!(:provider_organisation) { create(:provider, :placements, name: "Provider") }

        scenario "I am redirected to the list of my organisations" do
          given_i_am_signed_in_as_a_placements_user(
            organisations: [organisation, provider_organisation],
            sign_in: false,
          )
          when_i_visit_the_school_users_path(organisation)
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_on("Sign in using DfE Sign In")
          then_i_am_redirected_to_the_school_users_page(organisation)
          when_i_visit_the placements_root_path
          and_i_click_on "Start now"
          then_i_am_redirected_to_the_organisations_page
        end
      end

      context "when I sign in as support user Colin" do
        scenario "I am redirected to the support organisation list page" do
          given_there_are_placement_organisations
          given_i_am_signed_in_as_a_placements_support_user(sign_in: false)
          and_i_visit_a_school_show_page
          then_i_am_redirected_to_the_sign_in_page
          when_i_click_on("Sign in using DfE Sign In")
          then_i_see_school_show_page
          when_i_visit_the placements_root_path
          and_i_click_on "Start now"
          then_i_see_a_list_of_organisations
        end
      end
    end
  end

  private

  def and_i_visit_a_school_show_page
    visit placements_school_path(organisation)
  end

  def then_i_see_school_show_page
    expect(page).to have_current_path placements_school_path(organisation), ignore_query: true
    expect(page).to have_content(organisation.name)
  end

  def given_there_are_placement_organisations
    create(:school, :placements, name: "Placement School")
    create(:placements_provider, name: "Provider 1")
  end

  def and_i_click_on(text)
    click_on text
  end
  alias_method :when_i_click_on, :and_i_click_on

  def when_i_visit_the(path)
    visit path
  end

  def then_i_see_a_list_of_organisations
    expect(page).to have_current_path placements_support_organisations_path, ignore_query: true
    expect(page).to have_content("Placement School")
    expect(page).to have_content("Provider 1")
  end

  def then_i_dont_get_redirected_to_support_organisations
    expect(page).to have_no_current_path placements_support_organisations_path, ignore_query: true
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
    visit placements_support_organisations_path
  end

  def i_do_not_have_access_to_support_page
    expect(page).to have_content "You cannot perform this action"
  end

  def then_i_am_redirect_to_internal_server_error
    expect(page).to have_content("Sorry, there’s a problem with the service")
  end

  def when_i_visit_the_support_users_path
    visit placements_support_support_users_path
  end

  def then_i_am_redirected_to_the_sign_in_page
    expect(page).to have_current_path(sign_in_path)
  end

  def then_i_am_redirected_to_the_support_users_page
    expect(page).to have_current_path(placements_support_support_users_path)
  end

  def and_the_user_is_part_of_an_organisation(organisation)
    organisation.users << User.find_by(email: "anne_wilson@example.org")
  end

  def when_i_visit_the_school_users_path(organisation)
    visit placements_school_users_path(organisation)
  end

  def when_i_visit_the_placements_path
    visit placements_provider_placements_path(organisation)
  end

  def then_i_am_redirected_to_the_school_users_page(organisation)
    expect(page).to have_current_path(placements_school_users_path(organisation))
  end

  def then_i_am_redirected_to_the_organisations_page
    expect(page).to have_current_path(placements_organisations_path)
  end

  def then_i_can_see_the_placements_school_placements_page
    expect(page).to have_current_path(placements_school_placements_path(organisation))
  end

  def then_i_can_see_the_placements_page
    expect(page).to have_current_path(placements_provider_placements_path(organisation))
  end

  def and_i_see_an_empty_organsations_page
    expect(page).to have_current_path(placements_organisations_path)
    expect(page).to have_content("You are not a member of any placement organisations")
  end

  def when_i_visit_the_provider_users_path(organisation)
    visit placements_provider_users_path(organisation)
  end

  def then_i_am_redirected_to_the_provider_users_page(organisation)
    expect(page).to have_current_path(placements_provider_users_path(organisation))
  end

  def and_the_placements_user_is_also_a_support_user
    @current_user.update!(type: Placements::SupportUser)
  end
end
