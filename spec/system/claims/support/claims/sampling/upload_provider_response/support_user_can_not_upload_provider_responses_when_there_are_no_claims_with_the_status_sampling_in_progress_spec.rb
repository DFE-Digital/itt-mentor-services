require "rails_helper"

RSpec.describe "Support user can not upload provider responses when there are no claims with the status 'sampling_in_progress'",
               service: :claims,
               type: :system do
  scenario do
    given_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_no_sampling_claims_have_been_uploaded

    when_i_click_on_upload_provider_response
    then_i_see_there_are_no_claims_waiting_for_a_response
  end

  private

  def given_i_am_signed_in
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

  def when_i_click_on_upload_provider_response
    click_on "Upload provider response"
  end

  def then_i_see_there_are_no_claims_waiting_for_a_response
    expect(page).to have_title("You cannot upload a provider response - Auditing - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("You cannot upload a provider response")
    expect(page).to have_element(:span, text: "Auditing")
    expect(page).to have_element(
      :p,
      text: "You cannot upload a provider response as there are no claims waiting for a response.",
      class: "govuk-body",
    )
  end
end
