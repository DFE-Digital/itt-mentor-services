require "rails_helper"

RSpec.describe "Support user uploads ESFA responses for claims with the status 'clawback in progress'",
               service: :claims,
               type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawback_claims_index_page
    then_i_see_the_clawback_claims_index_page
    and_i_see_two_claims_with_the_status_clawback_in_progress

    when_i_click_on_upload_esfa_response
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_esfa_responses

    when_i_click_on_cancel
    then_i_see_the_clawback_claims_index_page

    when_i_click_on_upload_esfa_response
    and_i_click_on_cancel
    then_i_see_the_clawback_claims_index_page

    when_i_click_on_upload_esfa_response
    and_i_click_on_back
    then_i_see_the_clawback_claims_index_page

    when_i_click_on_upload_esfa_response
    and_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_esfa_responses

    when_i_click_on_back
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_esfa_responses

    when_i_click_upload_responses
    then_i_see_the_upload_has_been_successful
    and_i_can_not_see_claim_11111111
    and_i_can_not_see_claim_22222222

    when_i_navigate_to_the_all_claims_index_page
    then_i_can_see_claim_11111111_has_the_status_clawback_complete
    and_i_can_see_claim_22222222_has_the_status_clawback_complete
  end

  private

  def given_claims_exist
    @clawback_in_progress_claim_1 = create(:claim, :submitted, status: :clawback_in_progress, reference: 11_111_111)
    @clawback_in_progress_claim_2 = create(:claim, :submitted, status: :clawback_in_progress, reference: 22_222_222)

    mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    mentor_jane_doe = create(:claims_mentor, first_name: "Jane", last_name: "Doe")
    mentor_joe_bloggs = create(:claims_mentor, first_name: "Joe", last_name: "Bloggs")

    _john_smith_mentor_training = create(
      :mentor_training,
      :rejected,
      mentor: mentor_john_smith,
      claim: @clawback_in_progress_claim_1,
      hours_completed: 20,
    )
    _jane_doe_mentor_training = create(
      :mentor_training,
      :rejected,
      mentor: mentor_jane_doe,
      claim: @clawback_in_progress_claim_1,
      hours_completed: 20,
    )
    _joe_bloggs_mentor_training = create(
      :mentor_training,
      :rejected,
      mentor: mentor_joe_bloggs,
      claim: @clawback_in_progress_claim_2,
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
    have_element(:span, text: "Clawbacks", class: "govuk-caption-l")
    expect(page).to have_element(:label, text: "Upload CSV file")
  end

  def and_i_see_two_claims_with_the_status_clawback_in_progress
    expect(page).to have_h2("Clawbacks (2)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@clawback_in_progress_claim_1.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@clawback_in_progress_claim_1.id}",
      "status" => "Clawback in progress",
      "academic_year" => @clawback_in_progress_claim_1.academic_year.name,
      "provider_name" => @clawback_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @clawback_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
    expect(page).to have_claim_card({
      "title" => "22222222 - #{@clawback_in_progress_claim_2.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@clawback_in_progress_claim_2.id}",
      "status" => "Clawback in progress",
      "academic_year" => @clawback_in_progress_claim_2.academic_year.name,
      "provider_name" => @clawback_in_progress_claim_2.provider.name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim_2.submitted_at.to_date, format: :long),
      "amount" => @clawback_in_progress_claim_2.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def when_i_click_on_upload_esfa_response
    click_on "Upload payer response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def when_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress
    attach_file "Upload CSV file",
                "spec/fixtures/claims/clawback/esfa_responses/example_esfa_clawback_response_upload.csv"
  end
  alias_method :and_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress,
               :when_i_upload_a_csv_containing_esfa_responses_for_all_claims_with_the_status_clawback_in_progress

  def then_i_see_the_confirmation_page_for_uploading_esfa_responses
    expect(page).to have_title(
      "Confirm you want to upload the payer response - Clawbacks - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("Confirm you want to upload the payer response")
    have_element(:span, text: "Clawbacks", class: "govuk-caption-l")
    expect(page).to have_h2("example_esfa_clawback_response_upload.csv")
    expect(page).to have_table_row(
      "1" => "2",
      "claim_reference" => "11111111",
      "claim_status" => "clawback_complete",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "claim_reference" => "22222222",
      "claim_status" => "clawback_complete",
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
      "It may take a moment for the responses to load. Refresh the page to see newly uploaded information.",
    )
  end

  def and_i_can_not_see_claim_11111111
    expect(page).not_to have_claim_card({
      "title" => "11111111 - #{@clawback_in_progress_claim_1.school_name}",
    })
  end

  def and_i_can_not_see_claim_22222222
    expect(page).not_to have_claim_card({
      "title" => "22222222 - #{@clawback_in_progress_claim_2.school_name}",
    })
  end

  def when_i_navigate_to_the_all_claims_index_page
    within secondary_navigation do
      click_on "All claims"
    end
  end

  def then_i_can_see_claim_11111111_has_the_status_clawback_complete
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@clawback_in_progress_claim_1.school_name}",
      "url" => "/support/claims/#{@clawback_in_progress_claim_1.id}",
      "status" => "Clawback complete",
      "academic_year" => @clawback_in_progress_claim_1.academic_year.name,
      "provider_name" => @clawback_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @clawback_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def and_i_can_see_claim_22222222_has_the_status_clawback_complete
    expect(page).to have_claim_card({
      "title" => "22222222 - #{@clawback_in_progress_claim_2.school_name}",
      "url" => "/support/claims/#{@clawback_in_progress_claim_2.id}",
      "status" => "Clawback complete",
      "academic_year" => @clawback_in_progress_claim_2.academic_year.name,
      "provider_name" => @clawback_in_progress_claim_2.provider.name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim_2.submitted_at.to_date, format: :long),
      "amount" => @clawback_in_progress_claim_2.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end
end
