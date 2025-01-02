require "rails_helper"

RSpec.describe "ESFA user downloads clawback CSV with valid token", service: :claims, type: :system do
  scenario do
    given_one_of_my_claims_have_been_clawed_back
    and_the_token_is_valid

    when_i_visit_the_download_link_in_the_email
    then_i_see_the_download_page

    when_i_click_on_the_download_button
    then_the_csv_is_downloaded
  end

  private

  def given_one_of_my_claims_have_been_clawed_back
    @clawback = create(:claims_clawback)
  end

  def and_the_token_is_valid
    @token = Rails.application.message_verifier(:clawback).generate(@clawback.id, expires_in: 7.days)
  end

  def when_i_visit_the_download_link_in_the_email
    visit claims_clawback_claims_path(token: @token)
  end

  def then_i_see_the_download_page
    expect(page).to have_title("Download the clawback CSV - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Download the clawback CSV")
    expect(page).to have_element(:p, text: "Download the Claim funding for mentor training clawback CSV file.", class: "govuk-body")
    expect(page).to have_element(:p, text: "If you have any questions, email ittmentor.funding@education.gov.uk", class: "govuk-body")
    expect(page).to have_element(:a, text: "Download", class: "govuk-button")
  end

  def when_i_click_on_the_download_button
    click_on "Download"
  end

  def then_the_csv_is_downloaded
    current_time = Time.zone.now.utc.strftime("%Y-%m-%dT%H%%3A%M%%3A%SZ")
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"clawback-claims-#{current_time}.csv\"; filename*=UTF-8''clawback-claims-#{current_time}.csv")
  end
end
