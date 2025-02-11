require "rails_helper"

RSpec.describe "Support user uploads a CSV containing invalid references",
               service: :claims,
               type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_payments_claims_index_page
    then_i_see_the_payments_claims_index_page
    and_i_see_no_payment_claims_have_been_uploaded

    when_i_click_on_upload_payer_response
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_payer_responses_for_all_claims_with_the_status_payment_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_payer_responses

    when_i_click_on_back
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_payer_responses_for_all_claims_with_the_status_payment_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_payer_responses

    when_i_click_upload_responses
    then_i_see_the_upload_has_been_successful

    when_i_navigate_to_the_all_claims_index_page
    then_i_can_see_claim_11111111_has_the_status_paid
    and_i_can_see_claim_22222222_has_the_status_unpaid
  end

  private

  def given_claims_exist
    @payment_in_progress_claim_1 = create(:claim,
                                          :payment_in_progress,
                                          reference: 11_111_111)
    @payment_in_progress_claim_2 = create(:claim,
                                          :payment_in_progress,
                                          reference: 22_222_222)
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
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Payments")
    expect(page).to have_current_path(claims_support_claims_payments_path, ignore_query: true)
  end

  def then_i_see_the_upload_csv_page
    expect(page).to have_h1("Upload payer response")
    have_element(:span, text: "Payments", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_no_payment_claims_have_been_uploaded
    expect(page).to have_h2("Payments")
    expect(page).to have_element(:p, text: "There are no claims waiting to be processed.")
  end

  def when_i_click_on_upload_payer_response
    click_on "Upload payer response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def when_i_upload_a_csv_containing_payer_responses_for_all_claims_with_the_status_payment_in_progress
    attach_file "Upload CSV file",
                "spec/fixtures/claims/payment/example_payer_response.csv"
  end

  def then_i_see_the_confirmation_page_for_uploading_payer_responses
    expect(page).to have_title(
      "Confirm you want to upload the payer response - Payments - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("Confirm you want to upload the payer response")
    have_element(:span, text: "Payments", class: "govuk-caption-l")
    expect(page).to have_h2("example_payer_response.csv")
    expect(page).to have_table_row(
      "1" => "2",
      "claim_reference" => "11111111",
      "claim_status" => "paid",
      "unpaid_reason" => "",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "claim_reference" => "22222222",
      "claim_status" => "unpaid",
      "unpaid_reason" => "Some reason",
    )
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end
  alias_method :and_i_click_on_cancel, :when_i_click_on_cancel

  def when_i_click_on_back
    click_on "Back"
  end
  alias_method :and_i_click_on_back, :when_i_click_on_back

  def when_i_click_upload_responses
    click_on "Confirm upload"
  end

  def then_i_see_the_upload_has_been_successful
    expect(page).to have_success_banner(
      "Payer response uploaded",
      "The status of these claims have been updated to ‘paid’ or ‘payer needs information’. "\
      "It may take a moment for responses to load. Refresh the page to see newly uploaded information.",
    )
  end

  def when_i_navigate_to_the_all_claims_index_page
    within secondary_navigation do
      click_on "All claims"
    end
  end

  def then_i_can_see_claim_11111111_has_the_status_paid
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@payment_in_progress_claim_1.school_name}",
      "url" => "/support/claims/#{@payment_in_progress_claim_1.id}",
      "status" => "Paid",
      "academic_year" => @payment_in_progress_claim_1.academic_year.name,
      "provider_name" => @payment_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@payment_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @payment_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def and_i_can_see_claim_22222222_has_the_status_unpaid
    expect(page).to have_claim_card({
      "title" => "22222222 - #{@payment_in_progress_claim_2.school_name}",
      "url" => "/support/claims/#{@payment_in_progress_claim_2.id}",
      "status" => "Payer needs information",
      "academic_year" => @payment_in_progress_claim_2.academic_year.name,
      "provider_name" => @payment_in_progress_claim_2.provider.name,
      "submitted_at" => I18n.l(@payment_in_progress_claim_2.submitted_at.to_date, format: :long),
      "amount" => @payment_in_progress_claim_2.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end
end
