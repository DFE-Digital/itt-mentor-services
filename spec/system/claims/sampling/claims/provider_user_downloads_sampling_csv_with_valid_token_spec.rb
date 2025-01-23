require "rails_helper"

RSpec.describe "Provider user downloads sampling CSV with valid token", service: :claims, type: :system do
  scenario do
    given_one_of_my_claims_has_been_sampled
    and_the_token_is_valid

    when_i_visit_the_download_link_in_the_email
    then_i_see_the_download_page

    when_i_click_on_the_download_button
    then_the_csv_is_downloaded
    and_the_sampling_is_marked_as_downloaded
  end

  private

  def given_one_of_my_claims_has_been_sampled
    @provider_sampling = create(:provider_sampling)
    @download_access_token = create(:download_access_token, activity_record: @provider_sampling, email_address: @provider_sampling.provider.primary_email_address)
  end

  def and_the_token_is_valid
    @token = @download_access_token.generate_token_for(:csv_download)
  end

  def when_i_visit_the_download_link_in_the_email
    visit claims_sampling_claims_path(token: @token)
  end

  def then_i_see_the_download_page
    expect(page).to have_title("Download the CSV file - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Download the CSV file")
    expect(page).to have_element(:p, text: "Download the file to complete quality assurance on mentor funding claims associated with you. Instructions on how to complete the CSV file have been sent to you by email.", class: "govuk-body")
    expect(page).to have_element(:p, text: "If you need help, contact the team at ittmentor.funding@education.gov.uk", class: "govuk-body")
    expect(page).to have_element(:p, text: "The ability to download will expire 7 days after receiving the instructions via email. This is due to data security.", class: "govuk-body")
    expect(page).to have_element(:a, text: "Download CSV file", class: "govuk-button")
  end

  def when_i_click_on_the_download_button
    click_on "Download CSV file"
  end

  def then_the_csv_is_downloaded
    provider_name = @provider_sampling.provider_name.parameterize
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"quality_assurance_for_#{provider_name}_response.csv\"; filename*=UTF-8''quality_assurance_for_#{provider_name}_response.csv")
  end

  def and_the_sampling_is_marked_as_downloaded
    expect(@provider_sampling.reload.downloaded?).to be(true)
  end
end
