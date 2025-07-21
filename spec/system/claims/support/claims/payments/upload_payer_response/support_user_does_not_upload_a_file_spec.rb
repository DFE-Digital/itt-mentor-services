require "rails_helper"

RSpec.describe "Support user does not upload a file",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_payments_claims_index_page
    then_i_see_the_payments_claims_index_page
    and_i_see_a_claim_with_the_status_payment_in_progress

    when_i_click_on_upload_payer_response
    then_i_see_the_upload_csv_page

    when_i_click_on_upload_csv_file
    then_i_see_validation_error_regarding_invalid_data
  end

  private

  def given_claims_exist
    @claim = create(:claim,
                    :payment_in_progress,
                    reference: 11_111_111)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_payments_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Payments"
    end
  end

  def then_i_see_the_payments_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Payments")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Payments")
    expect(page).to have_current_path(claims_support_claims_payments_path, ignore_query: true)
  end

  def then_i_see_the_upload_csv_page
    expect(page).to have_h1("Upload payer response")
    have_element(:span, text: "Payments", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_a_claim_with_the_status_payment_in_progress
    expect(page).to have_claim_card({
      "title" => "#{@claim.reference} - #{@claim.school.name}",
      "url" => "/support/claims/payments/claims/#{@claim.id}",
      "status" => "Payer payment review",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider_name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_click_on_upload_payer_response
    click_on "Upload payer response"
  end

  def when_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def then_i_see_validation_error_regarding_invalid_data
    expect(page).to have_validation_error("Select a CSV file to upload")
  end
end
