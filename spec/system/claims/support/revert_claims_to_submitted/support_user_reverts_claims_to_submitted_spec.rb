require "rails_helper"

RSpec.describe "Support user reverts claims to submitted", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_claims_index_page
    then_i_can_see_a_paid_claim
    and_i_can_see_a_sampled_claim
    and_i_can_see_a_clawed_back_claim

    when_i_navigate_to_the_settings_page
    and_i_click_on_revert_all_claims_to_submitted
    then_i_see_the_page_to_review_all_claims_to_submitted

    when_i_click_revert_to_submitted
    then_i_see_a_success_message

    when_i_navigate_to_the_claims_index_page
    then_i_see_the_paid_claim_is_now_in_the_submitted_state
    and_i_see_the_sampled_claim_is_now_in_the_submitted_state
    and_i_see_the_clawed_back_claim_is_now_in_the_submitted_state
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

    @clawed_back_claim = create(:claim, :submitted, status: :clawback_complete)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end
  end

  def then_i_can_see_a_paid_claim
    expect(page).to have_claim_card({
      "title" => "#{@paid_claim.reference} - #{@paid_claim.school.name}",
      "url" => "/support/claims/#{@paid_claim.id}",
      "status" => "Paid",
      "academic_year" => @paid_claim.academic_year.name,
      "provider_name" => @paid_claim.provider_name,
      "submitted_at" => I18n.l(@paid_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_can_see_a_sampled_claim
    expect(page).to have_claim_card({
      "title" => "#{@sampling_claim.reference} - #{@sampling_claim.school.name}",
      "url" => "/support/claims/#{@sampling_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_claim.academic_year.name,
      "provider_name" => @sampling_claim.provider_name,
      "submitted_at" => I18n.l(@sampling_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_can_see_a_clawed_back_claim
    expect(page).to have_claim_card({
      "title" => "#{@clawed_back_claim.reference} - #{@clawed_back_claim.school.name}",
      "url" => "/support/claims/#{@clawed_back_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @clawed_back_claim.academic_year.name,
      "provider_name" => @clawed_back_claim.provider_name,
      "submitted_at" => I18n.l(@clawed_back_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_navigate_to_the_settings_page
    within primary_navigation do
      click_on "Settings"
    end
  end

  def and_i_click_on_revert_all_claims_to_submitted
    click_on "Revert all claims to 'Submitted'"
  end

  def then_i_see_the_page_to_review_all_claims_to_submitted
    expect(page).to have_h1(
      "Are you sure you want to revert all claims in the test environment database to 'Submitted'?",
    )
    expect(page).to have_element(:span, text: "Revert all claims to 'Submitted'", class: "govuk-caption-l")
  end

  def when_i_click_revert_to_submitted
    click_on "Revert to Submitted"
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner("Claims have been reverted to 'Submitted'")
  end

  def then_i_see_the_paid_claim_is_now_in_the_submitted_state
    expect(page).to have_claim_card({
      "title" => "#{@paid_claim.reference} - #{@paid_claim.school.name}",
      "url" => "/support/claims/#{@paid_claim.id}",
      "status" => "Submitted",
      "academic_year" => @paid_claim.academic_year.name,
      "provider_name" => @paid_claim.provider_name,
      "submitted_at" => I18n.l(@paid_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_is_now_in_the_submitted_state
    expect(page).to have_claim_card({
      "title" => "#{@sampling_claim.reference} - #{@sampling_claim.school.name}",
      "url" => "/support/claims/#{@sampling_claim.id}",
      "status" => "Submitted",
      "academic_year" => @sampling_claim.academic_year.name,
      "provider_name" => @sampling_claim.provider_name,
      "submitted_at" => I18n.l(@sampling_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_clawed_back_claim_is_now_in_the_submitted_state
    expect(page).to have_claim_card({
      "title" => "#{@clawed_back_claim.reference} - #{@clawed_back_claim.school.name}",
      "url" => "/support/claims/#{@clawed_back_claim.id}",
      "status" => "Submitted",
      "academic_year" => @clawed_back_claim.academic_year.name,
      "provider_name" => @clawed_back_claim.provider_name,
      "submitted_at" => I18n.l(@clawed_back_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end
end
