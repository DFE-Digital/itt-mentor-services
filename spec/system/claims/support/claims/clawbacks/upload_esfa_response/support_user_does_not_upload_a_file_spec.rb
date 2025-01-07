require "rails_helper"

RSpec.describe "Support user does not upload a file",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawback_claims_index_page
    then_i_see_the_clawback_claims_index_page
    and_i_see_a_claim_with_the_status_clawback_in_progress

    when_i_click_on_upload_esfa_response
    then_i_see_the_upload_csv_page

    when_i_click_on_upload_csv_file
    then_i_see_validation_error_regarding_invalid_data
  end

  private

  def given_claims_exist
    @claim = create(:claim,
                    :submitted,
                    status: :clawback_in_progress,
                    reference: 11_111_111)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawback_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def then_i_see_the_clawback_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
    expect(page).to have_current_path(claims_support_claims_clawbacks_path, ignore_query: true)
  end

  def then_i_see_the_upload_csv_page
    expect(page).to have_h1("Upload ESFA response")
    have_element(:span, text: "Sampling", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_a_claim_with_the_status_clawback_in_progress
    expect(page).to have_h2("Clawbacks (1)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@claim.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider.name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_click_on_upload_esfa_response
    click_on "Upload ESFA response"
  end

  def when_i_click_on_upload_csv_file
    click_on "Upload CSV file"
  end

  def then_i_see_validation_error_regarding_invalid_data
    expect(page).to have_validation_error("Select a CSV file to upload")
  end
end
