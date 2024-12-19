require "rails_helper"

RSpec.describe "Download payment claims", service: :claims, type: :system do
  let(:payment) { create(:claims_payment) }

  let(:valid_token) { Rails.application.message_verifier(:payments).generate(payment.id, expires_in: 7.days) }
  let(:invalid_token) { Rails.application.message_verifier(:payments).generate("invalid_id", expires_in: 7.days) }
  let(:expired_token) { Rails.application.message_verifier(:payments).generate(payment.id, expires_at: 10.days.ago) }
  let(:random_token) { "random" }

  scenario "ESFA user clicks on a valid link in their email inbox" do
    when_i_visit_the_download_url(token: valid_token)
    then_i_see_a_page_with_download_button

    when_i_click_on_the_download_button
    then_a_csv_file_is_downloaded
  end

  scenario "ESFA user clicks on an expired link in their email inbox" do
    when_i_visit_the_download_url(token: expired_token)
    then_i_see_an_error_page
  end

  scenario "ESFA user visits the url with an invalid token" do
    when_i_visit_the_download_url(token: invalid_token)
    then_i_see_an_error_page
  end

  scenario "ESFA user visits the url with a random token" do
    when_i_visit_the_download_url(token: random_token)
    then_i_see_an_error_page
  end

  scenario "ESFA user visits the url without a token" do
    when_i_visit_the_download_url(token: nil)
    then_i_see_an_error_page
  end

  private

  def when_i_visit_the_download_url(token:)
    visit claims_payments_claims_path(token:)
  end

  def then_i_see_a_page_with_download_button
    expect(page).to have_css("h1.govuk-heading-l", text: "Download payments file")
  end

  def then_i_see_an_error_page
    expect(page).to have_css("h1.govuk-heading-l", text: "Sorry, there is a problem with the download link")
    expect(page).to have_css("p.govuk-body", text: "You are seeing this page because the download link is not working. It may have timed out or contained an invalid security token.")
    expect(page).to have_css("p.govuk-body", text: "Email ittmentor.funding@education.gov.uk to request a new download link.")
  end

  def when_i_click_on_the_download_button
    click_on "Download CSV file"
  end

  def then_a_csv_file_is_downloaded
    expect(response_headers["Content-Type"]).to eq "text/csv"
  end
end
