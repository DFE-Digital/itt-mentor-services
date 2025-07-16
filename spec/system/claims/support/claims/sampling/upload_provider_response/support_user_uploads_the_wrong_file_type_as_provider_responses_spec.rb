require "rails_helper"

RSpec.describe "Support user uploads the wrong file type as provider responses",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_a_claim_with_the_status_sampling_in_progress

    when_i_click_on_upload_provider_response
    then_i_see_the_upload_csv_page

    when_i_upload_an_invalid_file_type
    and_i_click_on_upload_csv_file
    then_i_see_validation_error_regarding_invalid_file_type
  end

  private

  def given_claims_exist
    @claim = create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Auditing"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Auditing")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def then_i_see_the_upload_csv_page
    expect(page).to have_h1("Upload provider response")
    have_element(:span, text: "Auditing", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_a_claim_with_the_status_sampling_in_progress
    expect(page).to have_h2("Auditing (1)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@claim.school_name}",
      "url" => "/support/claims/sampling/claims/#{@claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider_name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_click_on_upload_provider_response
    click_on "Upload provider response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def then_i_see_validation_error_regarding_invalid_file_type
    expect(page).to have_validation_error("The selected file must be a CSV")
  end

  def when_i_upload_an_invalid_file_type
    tmp = Tempfile.new("invalid_upload.txt")
    attach_file "Upload CSV file", tmp.path
  end
end
