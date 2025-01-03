require "rails_helper"

RSpec.describe "Support user can not send claims to ESFA", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_clawbacks_index_page
    and_i_see_the_details_of_the_clawback_in_progress_claim

    when_i_click_on_send_claims_to_esfa
    then_i_see_the_are_no_claims_to_send_for_clawbacks
  end

  private

  def given_claims_exist
    @claim = create(:claim,
                    :submitted,
                    status: :clawback_in_progress)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawbacks_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def then_i_see_the_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Clawbacks (1)")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
    expect(page).to have_current_path(claims_support_claims_clawbacks_path, ignore_query: true)
  end

  def when_i_click_on_send_claims_to_esfa
    click_on "Send claims to ESFA"
  end

  def and_i_see_the_details_of_the_clawback_in_progress_claim
    expect(page).to have_claim_card({
      "title" => "#{@claim.reference} - #{@claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider.name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def then_i_see_the_are_no_claims_to_send_for_clawbacks
    expect(page).to have_title(
      "There are no claims to send for clawback - Clawbacks - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_h1("There are no claims to send for clawback")
    expect(page).to have_element(:p, text: "Clawbacks", class: "govuk-caption-l")
    expect(page).to have_element(
      :p,
      text: "You cannot send any claims to the ESFA because there are no claims with a clawback requested.",
    )
  end
end
