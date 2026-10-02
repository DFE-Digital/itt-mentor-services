require "rails_helper"

RSpec.describe "Support user submits claims when there are submitted claims for both claim windows", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in_as_a_support_user
    and_there_are_submitted_claims
    then_i_see_the_organisations_index_page

    when_i_click_on_claims
    and_i_click_on_payments
    then_i_see_the_payments_index_page

    when_i_click_on_send_claims_to_payer
    then_i_see_the_select_claim_window_page

    when_i_click_on_continue
    then_i_see_an_error_message

    when_i_select_the_current_claim_window
    and_i_click_on_continue
    then_i_see_the_send_claims_to_payer_page

    when_i_click_on_send_claims
    then_i_see_the_payments_index_page_with_confirmation_message
  end

  private

  def given_i_am_signed_in_as_a_support_user
    sign_in_claims_support_user
  end

  def and_there_are_submitted_claims
    @current_claim_window = create(:claim_window, :current).decorate
    @historic_claim_window = create(:claim_window, :historic).decorate
    create_list(:claim, 3, :submitted, claim_window: @current_claim_window)
    create_list(:claim, 2, :submitted, claim_window: @historic_claim_window)
  end

  def then_i_see_the_organisations_index_page
    expect(page).to have_title("Organisations (0) - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Organisations")
    expect(page).to have_h1("Organisations (0)")
  end

  def when_i_click_on_claims
    within primary_navigation do
      click_on "Claims"
    end
  end

  def and_i_click_on_payments
    within secondary_navigation do
      click_on "Payments"
    end
  end

  def then_i_see_the_payments_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(secondary_navigation).to have_current_item("Payments")
    expect(page).to have_h2("Payments")
  end

  def when_i_click_on_send_claims_to_payer
    click_on "Send claims to payer"
  end

  def then_i_see_the_select_claim_window_page
    expect(page).to have_title("Select claim window - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_span_caption("Submit claims to be paid")
    expect(page).to have_element(:legend, text: "Select claim window", class: "govuk-fieldset__legend")
    expect(page).to have_field("#{@current_claim_window.name} (current)", type: :radio)
    expect(page).to have_field(@historic_claim_window.name, type: :radio)
    expect(page).to have_link("Cancel", href: "/support/claims/payments")
  end

  def when_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_an_error_message
    expect(page).to have_title("Select claim window - Claim funding for mentor training - GOV.UK")
    expect(page).to have_element(:legend, text: "Select claim window", class: "govuk-fieldset__legend")
    expect(page).to have_validation_error("Please select a claim window")
  end

  def when_i_select_the_current_claim_window
    choose @current_claim_window.name
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_send_claims_to_payer_page
    expect(page).to have_title("Send claims to payer - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Send claims to payer")
    expect(page).to have_paragraph("There are 3 claims included in this submission.")
    expect(page).to have_paragraph("Selecting ‘Send claims’ will:")
    expect(page).to have_element(:li, text: "create a CSV containing a list of all ‘Submitted’ claims")
    expect(page).to have_element(:li, text: "send an email to the payer containing a link to the generated CSV - this link expires after 7 days")
    expect(page).to have_element(:li, text: "update the claim status from ‘Submitted’ to ‘Payment in progress’")
    expect(page).to have_warning_text("This action cannot be undone")
    expect(page).to have_button("Send claims")
    expect(page).to have_link("Cancel", href: "/support/claims/payments")
  end

  def when_i_click_on_send_claims
    click_on "Send claims"
  end

  def then_i_see_the_payments_index_page_with_confirmation_message
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(secondary_navigation).to have_current_item("Payments")
    expect(page).to have_h2("Payments")
    expect(page).to have_success_banner("Claims sent to payer", "The status of these claims have been updated to ‘Payer payment review’. You must wait for the payer to respond before you can take any further action on these claims.")
  end
end
