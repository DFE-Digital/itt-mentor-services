require "rails_helper"

RSpec.describe "Upload payer response CSV", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  scenario "Support user attempts to upload payer response, but there are no 'payment_in_progress' claims" do
    given_i_sign_in
    when_i_visit_claims_payments_index_page
    when_i_click_on_upload_esfa_response
    then_i_can_see_an_error_page
  end

  context "when there are claims with payment in progress" do
    before do
      create(:claim, :payment_in_progress, reference: "12345678")
      create(:claim, :payment_in_progress, reference: "23456789")
    end

    scenario "Support user sends claims to ESFA" do
      given_i_sign_in
      when_i_visit_claims_payments_index_page
      when_i_click_on_upload_esfa_response
      then_i_can_see_an_upload_form

      when_i_attach_a_csv_file
      and_i_click_on_upload_csv_file
      then_i_can_see_a_confirmation_page

      when_i_click_on_upload_response
      then_i_see_a_success_flash_message
      and_claims_have_been_paid_and_payment_information_requested
    end

    scenario "Support user attempts to upload payer response without attaching a file" do
      given_i_sign_in
      when_i_visit_claims_payments_index_page
      when_i_click_on_upload_esfa_response
      then_i_can_see_an_upload_form

      when_i_click_on_upload_csv_file
      then_i_see_the_error_message("Select a CSV file to upload")
    end
  end

  private

  def given_i_sign_in
    sign_in_as(support_user)
  end

  def when_i_visit_claims_payments_index_page
    click_on("Claims")
    click_on("Payments")
  end

  def when_i_click_on_upload_esfa_response
    click_on("Upload payer response")
  end

  def then_i_can_see_an_upload_form
    expect(page).to have_field("CSV file")
  end

  def then_i_can_see_an_error_page
    expect(page).to have_css("p.govuk-caption-l", text: "Payments")
    expect(page).to have_css("h1.govuk-heading-l", text: "You cannot upload a response from the payer")
    expect(page).to have_css("p.govuk-body", text: "You cannot upload a response from the payer as there are no claims waiting for a response.")
    expect(page).to have_link("Cancel", href: claims_support_claims_payments_path)
  end

  def when_i_attach_a_csv_file
    attach_file "CSV file", file_fixture("example-payments-response.csv")
  end

  def when_i_click_on_upload_csv_file
    click_on "Upload CSV file"
  end
  alias_method :and_i_click_on_upload_csv_file, :when_i_click_on_upload_csv_file

  def then_i_can_see_a_confirmation_page
    expect(page).to have_css("p.govuk-caption-l", text: "Payments")
    expect(page).to have_css("h1.govuk-heading-l", text: "Are you sure you want to upload the payer response?")
    expect(page).to have_css("p.govuk-body", text: "There are 5 claims included in this upload.")
  end

  def when_i_click_on_upload_response
    click_on("Upload response")
  end

  def then_i_see_a_success_flash_message
    expect(page).to have_content("Payer response uploaded")
  end

  def then_i_see_the_error_message(message)
    within(".govuk-error-summary") do
      expect(page).to have_content(message)
    end
  end

  def and_claims_have_been_paid_and_payment_information_requested
    expect(Claims::Claim.payment_in_progress.count).to eq(0)
    expect(Claims::Claim.paid.count).to eq(1)
    expect(Claims::Claim.payment_information_requested.count).to eq(1)
  end
end
