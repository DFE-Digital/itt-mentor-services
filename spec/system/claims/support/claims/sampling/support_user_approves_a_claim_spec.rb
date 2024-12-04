require "rails_helper"

RSpec.describe "Support user approves a claim", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    when_i_click_to_view_the_sampling_claim
    then_i_see_the_details_of_the_sampling_claim

    when_i_click_on_back
    then_i_see_the_sampling_claims_index_page

    when_i_click_to_view_the_sampling_claim
    then_i_see_the_sampling_reason

    when_i_click_on_approve_claim
    then_i_see_the_confirm_approval_page

    when_i_click_on_back
    then_i_see_the_details_of_the_sampling_claim

    when_i_click_on_approve_claim
    then_i_see_the_confirm_approval_page

    when_i_click_on_cancel
    then_i_see_the_details_of_the_sampling_claim

    when_i_click_on_approve_claim
    and_i_click_approve_claim_on_the_confirm_approval_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_a_success_message_for_updating_claim
    and_i_see_sampling_claim_is_no_longer_listed

    when_i_navigate_to_the_claims_index_page
    then_i_see_there_are_two_paid_claims
  end

  private

  def given_claims_exist
    @sampling_claim = create(:claim,
                             :submitted,
                             status: :sampling_in_progress,
                             sampling_reason: "Randomly selected for audit")

    @paid_claim = create(:claim,
                         :submitted,
                         status: :paid)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end
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
  end

  def when_i_click_to_view_the_paid_claim
    click_on "#{@paid_claim.reference} - #{@paid_claim.school.name}"
  end

  def when_i_click_to_view_the_sampling_claim
    click_on "#{@sampling_claim.reference} - #{@sampling_claim.school.name}"
  end

  def then_i_see_the_details_of_the_paid_claim
    expect(page).to have_title(
      "#{@paid_claim.school.name} - Claim #{@paid_claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Claim #{@paid_claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@paid_claim.school.name)
    expect(page).to have_element(:strong, text: "Paid", class: "govuk-tag govuk-tag--green")
  end

  def then_i_see_the_details_of_the_sampling_claim
    expect(page).to have_title(
      "#{@sampling_claim.school.name} - Sampling - Claim #{@sampling_claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Sampling - Claim #{@sampling_claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@sampling_claim.school.name)
    expect(page).to have_element(:strong, text: "Sampling in progress", class: "govuk-tag govuk-tag--purple")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def then_i_see_the_sampling_reason
    inset_text = page.find("div.govuk-inset-text")

    within(inset_text) do
      expect(page).to have_h3("Reason claim is being sampled")
      expect(page).to have_element(:p, text: "Randomly selected for audit", class: "govuk-body")
    end

    expect(page).to have_link("Approve claim", href: "/support/claims/sampling/#{@sampling_claim.id}/confirm_approval")
  end

  def when_i_click_on_approve_claim
    click_on "Approve claim"
  end
  alias_method :and_i_click_approve_claim_on_the_confirm_approval_page, :when_i_click_on_approve_claim

  def then_i_see_the_confirm_approval_page
    expect(page).to have_title("Are you sure you want to approve the claim? - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:p, text: "Sampling - Claim #{@sampling_claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1("Are you sure you want to approve the claim?")
    expect(page).to have_element(:p, text: "This will mark the claim as 'Paid'.", class: "govuk-body")
    expect(page).to have_button("Approve claim")
    expect(page).to have_link("Cancel", href: "/support/claims/sampling/#{@sampling_claim.id}")
  end

  def when_i_click_on_cancel
    click_on "Cancel"
  end

  def and_i_see_a_success_message_for_updating_claim
    expect(page).to have_success_banner("Claim updated")
  end

  def and_i_see_sampling_claim_is_no_longer_listed
    expect(page).to have_h2("Sampling")
    expect(page).not_to have_link("#{@sampling_claim.reference} - #{@sampling_claim.school.name}", href: "/support/claims/sampling/#{@sampling_claim.id}")
  end

  def then_i_see_there_are_two_paid_claims
    expect(page).to have_h2("Claims (2)")
    expect(page).to have_link("#{@sampling_claim.reference} - #{@sampling_claim.school.name}", href: "/support/claims/#{@sampling_claim.id}")
    expect(page).to have_link("#{@paid_claim.reference} - #{@paid_claim.school.name}", href: "/support/claims/#{@paid_claim.id}")
    expect(page).to have_element(:strong, text: "Paid", class: "govuk-tag govuk-tag--green", count: 2)
  end
end
