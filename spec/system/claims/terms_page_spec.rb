require "rails_helper"

RSpec.describe "Terms Page", service: :claims, type: :system do
  scenario "User visits the terms page" do
    given_i_am_on_the_terms_page
    then_i_can_see_the_terms_page
    and_i_can_see_the_purpose_of_the_service
    and_i_can_see_mentor_data_may_be_shared_with_accredited_providers
    and_i_can_see_when_the_terms_were_last_updated
  end

  private

  def given_i_am_on_the_terms_page
    visit claims_terms_path
  end

  def then_i_can_see_the_terms_page
    within(".govuk-heading-l") do
      expect(page).to have_content("Terms and conditions")
    end
  end

  def and_i_can_see_the_purpose_of_the_service
    expect(page).to have_content(
      "This Service is maintained to enable your organisation to claim funding for mentor training " \
      "and to support the administration of mentor training funding, as detailed in the Grant conditions.",
    )
    expect(page).to have_link("Grant conditions", href: claims_grant_conditions_path)
  end

  def and_i_can_see_mentor_data_may_be_shared_with_accredited_providers
    expect(page).to have_content(
      "may be shared with accredited providers for auditing purposes.",
    )
    expect(page).to have_content(
      "Accredited providers authorised to use the Service may access mentor information " \
      "where required to support programme administration and auditing activities.",
    )
  end

  def and_i_can_see_when_the_terms_were_last_updated
    expect(page).to have_content("Last updated 28 September 2026")
  end
end
