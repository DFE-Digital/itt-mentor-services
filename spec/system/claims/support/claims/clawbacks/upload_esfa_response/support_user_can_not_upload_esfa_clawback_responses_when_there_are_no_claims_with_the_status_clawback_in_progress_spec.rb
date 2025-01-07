require "rails_helper"

RSpec.describe "Support user can not upload ESFA clawback responses when there are no claims with the status 'clawback_in_progress'",
               service: :claims,
               type: :system do
  scenario do
    given_i_am_signed_in

    when_i_navigate_to_the_clawback_claims_index_page
    then_i_see_the_clawback_claims_index_page
    and_i_see_no_clawback_claims_have_been_uploaded

    when_i_click_on_upload_esfa_response
    then_i_see_there_are_no_claims_waiting_for_a_response
  end

  private

  def given_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawback_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def then_i_see_the_clawback_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
    expect(page).to have_current_path(claims_support_claims_clawbacks_path, ignore_query: true)
  end

  def and_i_see_no_clawback_claims_have_been_uploaded
    expect(page).to have_h2("Clawbacks")
    expect(page).to have_element(:p, text: "There are no claims waiting to be processed.")
  end

  def when_i_click_on_upload_esfa_response
    click_on "Upload ESFA response"
  end

  def then_i_see_there_are_no_claims_waiting_for_a_response
    expect(page).to have_title("You cannot upload an ESFA response - Clawbacks - Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("You cannot upload an ESFA response")
    expect(page).to have_element(:span, text: "Clawback")
    expect(page).to have_element(
      :p,
      text: "You cannot upload an ESFA response as there are no claims waiting for a response.",
      class: "govuk-body",
    )
  end
end
