require "rails_helper"

RSpec.describe "Support user changes the assigned support user on a claim",
               service: :claims,
               type: :system do
  scenario do
    given_support_users_exists
    and_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_claims_index_page
    then_i_see_the_claims_index_page
    and_i_see_a_claim_with_the_status_submitted

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim
    and_i_can_see_a_support_user_has_already_been_assigned

    when_i_click_change_assigned_user
    then_i_see_the_select_a_support_user_page
    and_see_the_support_user_has_been_preselected

    and_i_select_a_support_user
    and_i_click_continue
    then_i_see_the_details_of_the_claim
    and_i_see_the_support_user_has_been_assigned
  end

  private

  def and_claims_exist
    @claim = create(:claim, :submitted, reference: 11_111_111, support_user: @support_user_1)
  end

  def given_support_users_exists
    @support_user_1 = create(:claims_support_user, first_name: "Joe", last_name: "Bloggs")
    @support_user_2 = create(:claims_support_user, first_name: "Sarah", last_name: "Doe")
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end
  end

  def then_i_see_the_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("All claims")
    expect(page).to have_current_path(claims_support_claims_path, ignore_query: true)
  end

  def and_i_see_a_claim_with_the_status_submitted
    expect(page).to have_h2("Claims (1)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@claim.school_name}",
      "url" => "/support/claims/#{@claim.id}",
      "status" => "Submitted",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider_name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "0.00",
    })
  end

  def when_i_click_to_view_the_claim
    click_on "#{@claim.reference} - #{@claim.school.name}"
  end

  def then_i_see_the_details_of_the_claim
    expect(page).to have_title(
      "#{@claim.school.name} - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@claim.school.name)
    expect(page).to have_element(:strong, text: "Submitted", class: "govuk-tag govuk-tag--turquoise")
    expect(page).to have_current_path(claims_support_claim_path(@claim), ignore_query: true)
  end

  def and_i_can_see_a_support_user_has_already_been_assigned
    expect(page).to have_link("Change Assigned user")
    expect(page).to have_summary_list_row("Assigned user", "Joe Bloggs")
  end

  def when_i_click_change_assigned_user
    click_on "Change Assigned user"
  end

  def then_i_see_the_select_a_support_user_page
    expect(page).to have_title(
      "Assign a support agent - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :legend,
      text: "Assign a support agent",
      class: "govuk-fieldset__legend govuk-fieldset__legend--l",
    )
  end

  def and_see_the_support_user_has_been_preselected
    expect(page).to have_checked_field("Joe Bloggs")
  end

  def and_i_select_a_support_user
    choose "Joe Bloggs"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_see_the_support_user_has_been_assigned
    expect(page).to have_success_banner("Support agent assigned")
    expect(page).not_to have_link("Assign a support agent")
    expect(page).to have_summary_list_row("Assigned user", "Joe Bloggs")
  end
end
