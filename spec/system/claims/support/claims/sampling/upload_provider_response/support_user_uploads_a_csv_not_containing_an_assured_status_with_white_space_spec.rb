require "rails_helper"

RSpec.describe "Support user uploads a CSV containing an assured status with white space",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_two_claims_with_the_status_sampling_in_progress

    when_i_click_on_upload_provider_response
    then_i_see_the_upload_csv_page

    when_i_upload_a_file_not_containing_an_assured_status_for_each_mentor
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_provider_responses
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
    click_on "Upload"
  end

  def when_i_upload_a_file_not_containing_an_assured_status_for_each_mentor
    attach_file "Upload CSV file",
                "spec/fixtures/claims/sampling/provider_responses/valid_provider_response_upload_with_white_space_in_assured_status.csv"
  end

  def then_i_see_the_confirmation_page_for_uploading_provider_responses
    expect(page).to have_title(
      "Confirm you want to upload the provider response - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("Confirm you want to upload the provider response")
    expect(page).to have_element(:span, text: "Auditing", class: "govuk-caption-l")
    expect(page).to have_h2("valid_provider_response_upload_with_white_space_in_assured_status.csv")
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
      "claim_accepted" => "No",
      "rejection_reason" => "Another reason",
    )
    expect(page).to have_table_row(
      "1" => "4",
      "claim_reference" => "22222222",
      "mentor_full_name" => "Joe Bloggs",
      "claim_accepted" => "Yes",
      "rejection_reason" => "Yet another reason",
    )
  end
end
