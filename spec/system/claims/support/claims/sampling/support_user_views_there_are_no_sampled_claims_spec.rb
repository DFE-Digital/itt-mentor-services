require "rails_helper"

RSpec.describe "Support user views there are no sampled claims", service: :claims, type: :system do
  scenario do
    when_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_claims_sampling_claims_index_page
    and_i_see_there_are_no_claims_waiting_to_be_processed
  end

  private

  def when_i_am_signed_in
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

  def then_i_see_the_claims_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Auditing")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Auditing")
  end

  def and_i_see_there_are_no_claims_waiting_to_be_processed
    expect(page).to have_element(:p, text: "There are no claims waiting to be processed.", class: "govuk-body")
  end
end
