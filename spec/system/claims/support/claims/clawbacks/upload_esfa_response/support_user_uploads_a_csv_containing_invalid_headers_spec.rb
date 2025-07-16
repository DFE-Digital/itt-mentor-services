require "rails_helper"

RSpec.describe "Support user uploads a CSV containing invalid headers",
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

    when_i_upload_a_csv_containing_invalid_headers
    and_i_click_on_upload_csv_file
    then_i_see_validation_error_regarding_invalid_headers
  end

  private

  def given_claims_exist
    @clawback_in_progress_claim = create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)

    mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    mentor_jane_doe = create(:claims_mentor, first_name: "Jane", last_name: "Doe")

    _john_smith_mentor_training = create(
      :mentor_training,
      :rejected,
      mentor: mentor_john_smith,
      claim: @clawback_in_progress_claim,
      hours_completed: 20,
    )
    _jane_doe_mentor_training = create(
      :mentor_training,
      :rejected,
      mentor: mentor_jane_doe,
      claim: @clawback_in_progress_claim,
      hours_completed: 20,
    )
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
    expect(page).to have_h1("Upload payer response")
    have_element(:span, text: "Clawback", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_a_claim_with_the_status_clawback_in_progress
    expect(page).to have_h2("Clawbacks (1)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@clawback_in_progress_claim.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@clawback_in_progress_claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @clawback_in_progress_claim.academic_year.name,
      "provider_name" => @clawback_in_progress_claim.provider_name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim.submitted_at.to_date, format: :long),
      "amount" => @clawback_in_progress_claim.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def when_i_click_on_upload_esfa_response
    click_on "Upload payer response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def when_i_upload_a_csv_containing_invalid_headers
    attach_file "Upload CSV file",
                "spec/fixtures/claims/sampling/provider_responses/example_provider_response_upload.csv"
  end

  def then_i_see_validation_error_regarding_invalid_headers
    expect(page).to have_validation_error(
      "Your file needs a column called ‘claim_status’.",
    )
    expect(page).to have_element(
      :ul,
      text: "Right now it has columns called ‘claim_reference’, ‘mentor_full_name’, ‘claim_accepted’, and ‘rejection_reason’.",
      class: "govuk-error-summary__list",
    )
  end
end
