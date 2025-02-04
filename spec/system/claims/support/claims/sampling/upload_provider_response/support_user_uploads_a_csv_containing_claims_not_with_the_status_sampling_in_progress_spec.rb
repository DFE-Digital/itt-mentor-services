require "rails_helper"

RSpec.describe "Support user uploads a CSV containing claims not with the status 'sampling in progress'",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_a_claim_with_the_status_sampling_in_progress
    and_i_do_not_see_a_claim_with_the_status_paid

    when_i_click_on_upload_provider_response
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_a_claim_not_with_the_status_sampling_in_progress
    and_i_click_on_upload_csv_file
    then_i_see_the_errors_page
    and_i_see_the_csv_contained_claims_not_with_the_status_sampling_in_progress
  end

  private

  def given_claims_exist
    @sampling_in_progress_claim = create(:claim, :submitted, status: :sampling_in_progress, reference: 11_111_111)
    @paid_claim = create(:claim, :submitted, status: :paid, reference: 22_222_222)

    mentor_john_smith = create(:claims_mentor, first_name: "John", last_name: "Smith")
    mentor_jane_doe = create(:claims_mentor, first_name: "Jane", last_name: "Doe")
    mentor_joe_bloggs = create(:claims_mentor, first_name: "Joe", last_name: "Bloggs")

    _john_smith_mentor_training = create(
      :mentor_training,
      mentor: mentor_john_smith,
      claim: @sampling_in_progress_claim,
      hours_completed: 20,
    )
    _jane_doe_mentor_training = create(
      :mentor_training,
      mentor: mentor_jane_doe,
      claim: @sampling_in_progress_claim,
      hours_completed: 20,
    )
    _joe_bloggs_mentor_training = create(
      :mentor_training,
      mentor: mentor_joe_bloggs,
      claim: @paid_claim,
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

  def and_i_see_a_claim_with_the_status_sampling_in_progress
    expect(page).to have_h2("Auditing (1)")
    expect(page).to have_claim_card({
      "title" => "11111111 - #{@sampling_in_progress_claim.school_name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_in_progress_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_in_progress_claim.academic_year.name,
      "provider_name" => @sampling_in_progress_claim.provider.name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim.submitted_at.to_date, format: :long),
      "amount" => @sampling_in_progress_claim.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def and_i_do_not_see_a_claim_with_the_status_paid
    expect(page).not_to have_claim_card({
      "title" => "22222222 - #{@paid_claim.school_name}",
    })
  end

  def when_i_click_on_upload_provider_response
    click_on "Upload provider response"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def when_i_upload_a_csv_containing_a_claim_not_with_the_status_sampling_in_progress
    attach_file "Upload CSV file",
                "spec/fixtures/claims/sampling/provider_responses/example_provider_response_upload.csv"
  end

  def then_i_see_the_errors_page
    expect(page).to have_title(
      "Upload provider response - Auditing - Claims - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("Upload provider response")
  end

  def and_i_see_the_csv_contained_claims_not_with_the_status_sampling_in_progress
    expect(page).to have_h1("Upload provider response")
    expect(page).to have_element(:div, text: "You need to fix 1 error related to specific rows", class: "govuk-error-summary")
    expect(page).to have_element(:td, text: "Enter a valid claim reference 22222222", class: "govuk-table__cell")
    expect(page).to have_element(:p, text: "Only showing rows with errors", class: "govuk-!-text-align-centre")
  end
end
