require "rails_helper"

RSpec.describe "Support user uploads provider responses for claims with the status 'sampling in progress'",
               service: :claims,
               type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_two_claims_with_the_status_sampling_in_progress

    when_i_click_on_upload_provider_response
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_provider_responses

    when_i_click_on_cancel
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_provider_response
    and_i_click_on_cancel
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_provider_response
    and_i_click_on_back
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_provider_response
    and_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_provider_responses

    when_i_click_on_back
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_provider_responses

    when_i_click_upload_responses
    then_i_see_the_upload_has_been_successful
    and_i_can_see_claim_11111111_has_the_status_provider_not_approved
    and_i_can_not_see_claim_22222222

    when_i_navigate_to_the_all_claims_index_page
    then_i_can_see_claim_11111111_has_the_status_provider_not_approved_on_the_all_claims_index_page
    and_i_can_see_claim_22222222_has_the_status_paid_on_the_all_claims_index_page
  end

  private

  def given_claims_exist
    @sampling_in_progress_claim_1 = create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
    @sampling_in_progress_claim_2 = create(:claim, :submitted, status: :sampling_in_progress, reference: 22_222_222)

    mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    mentor_jane_doe = create(:claims_mentor, first_name: "Jane", last_name: "Doe")
    mentor_joe_bloggs = create(:claims_mentor, first_name: "Joe", last_name: "Bloggs")

    _john_smith_mentor_training = create(
      :mentor_training,
      mentor: mentor_john_smith,
      claim: @sampling_in_progress_claim_1,
      hours_completed: 20,
    )
    _jane_doe_mentor_training = create(
      :mentor_training,
      mentor: mentor_jane_doe,
      claim: @sampling_in_progress_claim_1,
      hours_completed: 20,
    )
    _joe_bloggs_mentor_training = create(
      :mentor_training,
      mentor: mentor_joe_bloggs,
      claim: @sampling_in_progress_claim_2,
      hours_completed: 20,
    )
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

  def and_i_see_two_claims_with_the_status_sampling_in_progress
    expect(page).to have_h2("Auditing (2)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@sampling_in_progress_claim_1.school_name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_in_progress_claim_1.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_in_progress_claim_1.academic_year.name,
      "provider_name" => @sampling_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
    expect(page).to have_claim_card({
      "title" => "22222222 - #{@sampling_in_progress_claim_2.school_name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_in_progress_claim_2.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_in_progress_claim_2.academic_year.name,
      "provider_name" => @sampling_in_progress_claim_2.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim_2.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim_2.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def when_i_click_on_upload_provider_response
    click_on "Upload provider response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload CSV file"
  end

  def when_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress
    attach_file "Upload CSV file",
                "spec/fixtures/claims/sampling/provider_responses/example_provider_response_upload.csv"
  end
  alias_method :and_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress,
               :when_i_upload_a_csv_containing_provider_responses_for_all_claims_with_the_status_sampling_in_progress

  def then_i_see_the_confirmation_page_for_uploading_provider_responses
    expect(page).to have_title(
      "Upload provider response - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("Upload provider response")
    expect(page).to have_element(:span, text: "Auditing", class: "govuk-caption-l")
    expect(page).to have_element(:p, text: "Confirm these are the provider details you want to upload.", class: "govuk-body")
    expect(page).to have_h2("example_provider_response_upload.csv")
    expect(page).to have_table_row(
      "1" => "2",
      "claim_reference" => "11111111",
      "mentor_full_name" => "John Smith",
      "claim_accepted" => "yes",
      "rejection_reason" => "Some reason",
    )
    expect(page).to have_table_row(
      "1" => "3",
      "claim_reference" => "11111111",
      "mentor_full_name" => "Jane Doe",
      "claim_accepted" => "no",
      "rejection_reason" => "Another reason",
    )
    expect(page).to have_table_row(
      "1" => "4",
      "claim_reference" => "22222222",
      "mentor_full_name" => "Joe Bloggs",
      "claim_accepted" => "yes",
      "rejection_reason" => "Yet another reason",
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
      "Provider response uploaded",
      "It may take a moment for the responses to load",
    )
  end

  def then_i_can_see_claim_11111111_has_the_status_provider_not_approved
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@sampling_in_progress_claim_1.school_name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_in_progress_claim_1.id}",
      "status" => "Provider not approved",
      "academic_year" => @sampling_in_progress_claim_1.academic_year.name,
      "provider_name" => @sampling_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end
  alias_method :and_i_can_see_claim_11111111_has_the_status_provider_not_approved,
               :then_i_can_see_claim_11111111_has_the_status_provider_not_approved

  def and_i_can_not_see_claim_22222222
    expect(page).not_to have_claim_card({
      "title" => "22222222 - #{@sampling_in_progress_claim_2.school_name}",
    })
  end

  def when_i_navigate_to_the_all_claims_index_page
    within secondary_navigation do
      click_on "All claims"
    end
  end

  def then_i_can_see_claim_11111111_has_the_status_provider_not_approved_on_the_all_claims_index_page
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@sampling_in_progress_claim_1.school_name}",
      "url" => "/support/claims/#{@sampling_in_progress_claim_1.id}",
      "status" => "Provider not approved",
      "academic_year" => @sampling_in_progress_claim_1.academic_year.name,
      "provider_name" => @sampling_in_progress_claim_1.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim_1.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim_1.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def and_i_can_see_claim_22222222_has_the_status_paid_on_the_all_claims_index_page
    expect(page).to have_claim_card({
      "title" => "22222222 - #{@sampling_in_progress_claim_2.school_name}",
      "url" => "/support/claims/#{@sampling_in_progress_claim_2.id}",
      "status" => "Paid",
      "academic_year" => @sampling_in_progress_claim_2.academic_year.name,
      "provider_name" => @sampling_in_progress_claim_2.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim_2.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim_2.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end
end
