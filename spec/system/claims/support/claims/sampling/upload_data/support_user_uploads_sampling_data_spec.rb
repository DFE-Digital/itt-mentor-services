require "rails_helper"

RSpec.describe "Support user uploads sampling data", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_no_sampling_claims_have_been_uploaded

    when_i_click_on_upload_claims_to_be_sampled
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_a_valid_sampling_data
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_the_sampling_data

    when_i_click_on_cancel
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_claims_to_be_sampled
    and_i_click_on_cancel
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_claims_to_be_sampled
    and_i_click_on_back
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_claims_to_be_sampled
    and_i_upload_a_csv_containing_a_valid_sampling_data
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_the_sampling_data

    when_i_click_on_back
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_containing_a_valid_sampling_data
    and_i_click_on_upload_csv_file
    then_i_see_the_confirmation_page_for_uploading_the_sampling_data

    when_i_click_upload_data
    then_i_see_the_upload_has_been_successful
  end

  private

  def given_claims_exist
    @current_academic_year = AcademicYear.for_date(Time.current) || create(:academic_year, :current)

    current_claim_window = create(:claim_window, academic_year: @current_academic_year,
                                                 starts_on: @current_academic_year.starts_on,
                                                 ends_on: @current_academic_year.starts_on + 2.days)

    provider = create(:claims_provider)

    @current_claim = create(:claim,
                            :submitted,
                            status: :paid,
                            claim_window: current_claim_window,
                            reference: 11_111_111,
                            provider:)
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

  def and_i_see_no_sampling_claims_have_been_uploaded
    expect(page).to have_h2("Auditing")
    expect(page).to have_element(:p, text: "There are no claims waiting to be processed.")
  end

  def when_i_click_on_upload_claims_to_be_sampled
    click_on "Upload claims to be audited"
  end

  def when_i_upload_a_csv_containing_a_valid_sampling_data
    attach_file "Upload CSV file", "spec/fixtures/claims/sampling/example_sampling_upload.csv"
  end
  alias_method :and_i_upload_a_csv_containing_a_valid_sampling_data,
               :when_i_upload_a_csv_containing_a_valid_sampling_data

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def then_i_see_the_confirmation_page_for_uploading_the_sampling_data
    expect(page).to have_h1("Confirm you want to upload claims to be audited")
    have_element(:span, text: "Auditing", class: "govuk-caption-l")
    expect(page).to have_table_row(
      "1" => "2",
      "claim_reference" => "11111111",
      "sample_reason" => "Some Reason",
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

  def then_i_see_the_upload_csv_page
    expect(page).to have_h1("Upload claims to be audited")
    have_element(:span, text: "Auditing", class: "govuk-caption-l")
  end

  def when_i_click_upload_data
    click_on "Confirm upload"
  end

  def then_i_see_the_upload_has_been_successful
    expect(page).to have_success_banner("Auditing data uploaded")
    expect(page).to have_h2("Auditing (1)")
    expect(page).to have_claim_card({
      "title" => "#{@current_claim.reference} - #{@current_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@current_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @current_claim.academic_year.name,
      "provider_name" => @current_claim.provider_name,
      "submitted_at" => I18n.l(@current_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end
end
