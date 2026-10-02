require "rails_helper"

RSpec.describe "Support user submits claims when there are submitted claims for one claim window", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in_as_a_support_user
    and_there_are_submitted_claims
    then_i_see_the_organisations_index_page

    when_i_click_on_claims
    and_i_click_on_payments
    then_i_see_the_payments_index_page

    when_i_click_on_send_claims_to_payer
    then_i_see_the_select_claim_window_page
    and_i_do_not_see_the_historic_claim_window_option
  end

  private

  def given_i_am_signed_in_as_a_support_user
    sign_in_claims_support_user
  end

  def and_there_are_submitted_claims
    @current_claim_window = create(:claim_window, :current).decorate
    @historic_claim_window = create(:claim_window, :historic).decorate
    create_list(:claim, 3, :submitted, claim_window: @current_claim_window)
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
    expect(page).to have_link("Cancel", href: "/support/claims/payments")
  end

  def and_i_do_not_see_the_historic_claim_window_option
    expect(page).not_to have_field(@historic_claim_window.name, type: :radio)
  end
end
