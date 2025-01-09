require "rails_helper"

RSpec.describe "ESFA user downloads a payment CSV which has already been downloaded", service: :claims, type: :system do
  scenario do
    given_one_of_my_claims_have_been_paid
    and_the_token_is_invalid

    when_i_visit_the_download_link_in_the_email
    then_i_see_the_error_page
  end

  private

  def given_one_of_my_claims_have_been_paid
    @payment = create(:claims_payment, downloaded_at: Time.current)
  end

  def and_the_token_is_invalid
    @token = Rails.application.message_verifier(:payments).generate(@payment.id, expires_in: 7.days)
  end

  def when_i_visit_the_download_link_in_the_email
    visit claims_payments_claims_path(token: @token)
  end

  def then_i_see_the_error_page
    expect(page).to have_title("Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Sorry, there is a problem with the download link")
    expect(page).to have_element(:p, text: "You are seeing this page because the download link is not working. It may have timed out or contained an invalid security token.", class: "govuk-body")
    expect(page).to have_element(:p, text: "Email ittmentor.funding@education.gov.uk to request a new download link.", class: "govuk-body")
  end
end
