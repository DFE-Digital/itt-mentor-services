require "rails_helper"

RSpec.describe "Support user uploads a CSV file with the wrong headers",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_on_upload_claims_to_be_audited
    then_i_see_the_upload_csv_page

    when_i_upload_a_csv_file_not_containing_invalid_headers
    and_i_click_on_upload_csv_file
    then_i_see_validation_error_regarding_invalid_headers
  end

  private

  def given_claims_exist
    @paid_claim_1 = create(:claim, :submitted, status: :paid, reference: 11_111_111)
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
    expect(page).to have_h1("Upload claims to be audited")
    have_element(:span, text: "Auditing", class: "govuk-caption-l")
  end

  def when_i_click_on_upload_claims_to_be_audited
    click_on "Upload claims to be audited"
  end

  def and_i_click_on_upload_csv_file
    click_on "Upload"
  end

  def when_i_upload_a_csv_file_not_containing_invalid_headers
    attach_file "Upload CSV file",
                "spec/fixtures/claims/sampling/invalid_headers_sampling_upload.csv"
  end

  def then_i_see_validation_error_regarding_invalid_headers
    expect(page).to have_css(".govuk-error-summary__list", text: "Your file needs a column called ‘claim_reference’ and ‘sample_reason’")
    expect(page).to have_css(".govuk-error-summary__list", text: "Right now it has columns called ‘claim_refrence’ and ‘sampl_reason’.")
  end
end
