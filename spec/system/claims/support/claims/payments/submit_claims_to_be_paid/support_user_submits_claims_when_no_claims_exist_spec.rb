require "rails_helper"

RSpec.describe "Support user submits claims when no claims exist", service: :claims, type: :system do
  scenario do
    given_i_am_signed_in_as_a_support_user
    then_i_see_the_organisations_index_page

    when_i_click_on_claims
    and_i_click_on_payments
    then_i_see_the_payments_index_page

    when_i_click_on_send_claims_to_payer
    then_i_see_an_error_page
  end

  private

  def given_i_am_signed_in_as_a_support_user
    sign_in_claims_support_user
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

  def then_i_see_an_error_page
    expect(page).to have_title("There are no claims to send for payment - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("There are no claims to send for payment")
    expect(page).to have_element(:p, text: "Submit claims to be paid", class: "govuk-caption-l")
    expect(page).to have_paragraph("You cannot send any claims to the payer because there are no claims pending payment.")
    expect(page).to have_link("Cancel", href: "/support/claims/payments")
  end
end
