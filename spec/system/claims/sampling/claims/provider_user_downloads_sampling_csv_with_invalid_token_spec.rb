require "rails_helper"

RSpec.describe "Provider user downloads a sampling CSV with invalid token", service: :claims, type: :system do
  scenario do
    given_one_of_my_claims_has_been_sampled
    and_the_token_is_invalid

    when_i_visit_the_download_link_in_the_email
    then_i_see_the_error_page
  end

  private

  def given_one_of_my_claims_has_been_sampled
    @provider_sampling = create(:provider_sampling)
  end

  def and_the_token_is_invalid
    @token = Rails.application.message_verifier(:bobs_burgers).generate(@provider_sampling.id, expires_in: 7.days)
  end

  def when_i_visit_the_download_link_in_the_email
    visit claims_sampling_claims_path(token: @token)
  end

  def then_i_see_the_error_page
    expect(page).to have_h1("Sorry, there is a problem with the download link")
    expect(page).to have_element(:p, text: "You are seeing this page because the download link is not working. It may have timed out or contained an invalid security token.", class: "govuk-body")
    expect(page).to have_element(:p, text: "Email ittmentor.funding@education.gov.uk to request a new download link.", class: "govuk-body")
  end
end
