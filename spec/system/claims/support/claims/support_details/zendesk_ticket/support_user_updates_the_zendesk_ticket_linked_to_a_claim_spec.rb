require "rails_helper"

RSpec.describe "Support user updates the zendesk ticket linked to claim", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_claims_index_page
    then_i_see_the_claims_index_page
    and_i_see_a_claim_with_the_status_submitted

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim
    and_i_can_see_a_support_ticket_has_been_assigned

    when_i_click_change_zendesk_ticket
    then_i_see_the_zendesk_url_input_page
    and_see_the_input_pre_fiiled_with_the_zendesk_link

    when_i_enter_a_zendesk_ticket_url
    and_i_click_continue
    then_i_see_the_details_of_the_claim
    and_i_see_the_zendesk_ticket_url_has_been_added
  end

  private

  def given_claims_exist
    @claim = create(:claim,
                    :submitted,
                    reference: 11_111_111,
                    zendesk_url: "example.zendesk.com")
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

  def and_i_can_see_a_support_ticket_has_been_assigned
    expect(page).to have_link("Zendesk ticket (opens in new tab)", href: "example.zendesk.com")
  end

  def when_i_click_change_zendesk_ticket
    click_on "Change Support ticket"
  end

  def then_i_see_the_zendesk_url_input_page
    expect(page).to have_title(
      "Enter a URL for the associated Zendesk ticket - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(
      :label,
      text: "Enter a URL for the associated Zendesk ticket",
      class: "govuk-label govuk-label--l",
    )
  end

  def when_i_enter_a_zendesk_ticket_url
    fill_in "Enter a URL for the associated Zendesk ticket", with: "another_example.zendesk.com"
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def and_i_see_the_zendesk_ticket_url_has_been_added
    expect(page).to have_success_banner("Link to Zendesk ticket added")
    expect(page).not_to have_link("Add link to Zendesk ticket")
    expect(page).to have_link("Zendesk ticket (opens in new tab)", href: "another_example.zendesk.com")
  end

  def and_see_the_input_pre_fiiled_with_the_zendesk_link
    find_field "Enter a URL for the associated Zendesk ticket", with: "example.zendesk.com"
  end
end
