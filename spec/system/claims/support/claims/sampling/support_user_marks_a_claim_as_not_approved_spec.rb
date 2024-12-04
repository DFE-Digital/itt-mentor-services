require "rails_helper"

RSpec.describe "Support user marks a claim as not approved", service: :claims, type: :system do
  scenario do
    given_a_claim_exists
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_claim
    then_i_see_the_details_of_the_claim

    when_i_click_on_reject_claim
    then_i_see_the_confirmation_page

    when_i_click_on_cancel
    then_i_see_the_details_of_the_claim

    when_i_click_on_reject_claim
    and_i_click_on_reject_claim
    then_i_see_the_sampling_claims_index_page
    and_i_see_that_the_claim_has_been_updated
    and_i_do_not_see_the_claim_in_the_sampling_index_page

    when_i_navigate_to_the_all_claims_index_page
    then_i_see_that_the_claim_has_been_updated_to_not_approved
  end

  private

  def given_a_claim_exists
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Sampling"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Sampling")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def when_i_click_to_view_the_claim
    click_on "#{@claim.reference} - #{@claim.school.name}"
  end

  def then_i_see_the_details_of_the_claim
    expect(page).to have_title(
      "#{@claim.school.name} - Sampling - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Sampling - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@claim.school.name)
    expect(page).to have_element(:strong, text: "Provider not approved", class: "govuk-tag govuk-tag--pink")
  end

  def when_i_click_on_reject_claim
    click_on "Reject claim"
  end
  alias_method :and_i_click_on_reject_claim, :when_i_click_on_reject_claim

  def then_i_see_the_confirmation_page
    expect(page).to have_title(
      "Are you sure you want to reject the claim? - Sampling - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:span, text: "Sampling - Claim #{@claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1("Are you sure you want to reject the claim?")
    expect(page).to have_element(
      :p,
      text: "This will mark the claim as 'Claim not approved' and move it into the clawbacks queue.",
      class: "govuk-body",
    )
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def and_i_see_that_the_claim_has_been_updated
    expect(page).to have_success_banner("Claim updated")
  end

  def and_i_do_not_see_the_claim_in_the_sampling_index_page
    expect(page).not_to have_claim_card({
      "title" => "#{@claim.reference} - #{@claim.school.name}",
    })
  end

  def when_i_navigate_to_the_all_claims_index_page
    within secondary_navigation do
      click_on "All claims"
    end
  end

  def then_i_see_that_the_claim_has_been_updated_to_not_approved
    expect(page).to have_claim_card({
      "title" => "#{@claim.reference} - #{@claim.school.name}",
      "url" => "/support/claims/sampling/#{@claim.id}",
      "status" => "Sampling not approved",
      "academic_year" => @claim.academic_year.name,
      "provider_name" => @claim.provider.name,
      "submitted_at" => I18n.l(@claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end
end
