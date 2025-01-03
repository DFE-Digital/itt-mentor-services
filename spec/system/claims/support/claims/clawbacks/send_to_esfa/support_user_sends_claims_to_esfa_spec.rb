require "rails_helper"

RSpec.describe "Support user sends claims to ESFA", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_clawbacks_index_page
    and_i_see_the_details_of_the_clawback_requested_claim

    when_i_click_on_send_claims_to_esfa
    then_i_can_see_a_confirmation_page

    when_i_click_on_send_claims
    then_i_see_a_success_message
    and_the_clawback_requested_claims_status_has_changed_to_clawback_in_progress
  end

  private

  def given_claims_exist
    @claim = create(:claim,
                    :submitted,
                    status: :clawback_requested)
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

  def then_i_can_see_a_confirmation_page
    expect(page).to have_element(:p, text: "Clawbacks", class: "govuk-caption-l")
    expect(page).to have_h1("Send claims to ESFA")
    expect(page).to have_element(:p, text: "There is 1 claim included in this submission.", class: "govuk-body")
    expect(page).to have_element(:div, text: "Selecting ‘Send claims’ will:", class: "govuk-body")
    expect(page).to have_element(
      :li,
      text: "create a CSV containing a list of all claims marked as ‘Clawback requested’",
    )
    expect(page).to have_element(
      :li,
      text: "send an email to the ESFA containing a link to the generated CSV - this link expires after 7 days",
    )
    expect(page).to have_element(
      :li,
      text: "update the claim status from ‘Clawback requested’ to ‘Clawback in progress’",
    )
    expect(page).to have_warning_text("This action cannot be undone.")
  end

  def when_i_click_on_send_claims
    click_on "Send claims"
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner("Claims sent to ESFA")
  end

  def and_i_see_the_details_of_the_clawback_requested_claim
    expect(page).to have_claim_card({
      "title" => "#{@claim.reference} - #{@claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@claim.id}",
      "status" => "Clawback requested",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider.name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_the_clawback_requested_claims_status_has_changed_to_clawback_in_progress
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
end
