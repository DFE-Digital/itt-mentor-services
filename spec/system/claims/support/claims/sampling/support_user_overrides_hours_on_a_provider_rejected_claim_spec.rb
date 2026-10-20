require "rails_helper"

RSpec.describe "Support user overrides hours on a provider rejected claim", service: :claims, type: :system do
  scenario "overriding the hours amended by the provider before the evidence deadline" do
    given_a_provider_rejected_claim_exists
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_the_override_hours_link
    then_the_mentor_who_was_amended_by_the_provider_is_selected

    when_i_select_both_mentors
    and_i_click_on_continue
    then_i_see_the_hours_page_for_james_chess
    and_the_provider_amendment_is_prefilled

    when_i_enter_12_hours_and_a_reason
    and_i_click_on_continue
    then_i_see_the_hours_page_for_sarah_doe

    when_i_choose_to_remove_all_hours_and_enter_a_reason
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_overridden_hours

    and_i_click_on_confirm
    then_the_clawback_is_requested_with_a_success_message
    and_the_claim_requires_clawback_approval
    and_the_hours_are_overridden
    and_the_activity_is_recorded
  end

  scenario "before the evidence deadline" do
    given_a_provider_rejected_claim_exists(notified_at: 1.day.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_the_override_hours_link
    and_i_click_on_continue
    and_i_click_on_continue
    and_i_click_on_confirm
    then_the_clawback_is_requested_with_a_success_message
    and_the_activity_is_recorded
  end

  scenario "without a reason" do
    given_a_provider_rejected_claim_exists(notified_at: 1.day.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_the_override_hours_link
    and_i_click_on_continue
    and_i_clear_the_reason
    and_i_click_on_continue
    then_i_see_a_reason_error
  end

  scenario "when the school evidence supports all of the hours claimed" do
    given_a_provider_rejected_claim_exists(notified_at: 1.day.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_the_override_hours_link
    and_i_click_on_continue
    and_i_enter_all_of_the_hours_claimed
    and_i_click_on_continue
    and_i_click_on_confirm
    then_the_claim_is_moved_to_paid
  end

  scenario "from the claim page after the evidence deadline" do
    given_a_provider_rejected_claim_exists(notified_at: 60.days.ago)
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_the_override_hours_link
    and_i_click_on_continue
    and_i_click_on_continue
    and_i_click_on_confirm
    then_the_clawback_is_requested_with_a_success_message
  end

  scenario "the claim is not rejected by the provider" do
    given_a_claim_in_sampling_exists
    and_i_am_signed_in

    when_i_visit_the_override_page_directly
    then_i_am_returned_to_the_claim
  end

  private

  def given_a_provider_rejected_claim_exists(notified_at: 1.day.ago)
    @notified_at = notified_at
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved,
                    amendment_notification_sent_at: @notified_at)
    @james = create(:claims_mentor, first_name: "James", last_name: "Chess")
    @sarah = create(:claims_mentor, first_name: "Sarah", last_name: "Doe")
    @james_training = create(:mentor_training,
                             claim: @claim,
                             mentor: @james,
                             hours_completed: 15,
                             not_assured: true,
                             reason_not_assured: "Incorrect number of hours",
                             hours_clawed_back: 4)
    @sarah_training = create(:mentor_training, claim: @claim, mentor: @sarah, hours_completed: 10)
  end

  def given_a_claim_in_sampling_exists
    @claim = create(:claim, :submitted, status: :sampling_in_progress)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_view_the_claim
    visit claims_support_claims_sampling_path(@claim)
  end

  def and_i_click_on_the_override_hours_link
    click_on "Override hours"
  end

  def and_i_clear_the_reason
    fill_in "Why are you overriding this?", with: ""
  end

  def then_i_see_a_reason_error
    expect(page).to have_content("Please enter a reason")
  end

  def and_i_enter_all_of_the_hours_claimed
    fill_in "Number of hours", with: "15"
  end

  def then_the_claim_is_moved_to_paid
    expect(page).to have_success_banner("Hours of training overridden. Claim has been moved to the paid status")
    expect(@claim.reload).to be_paid
  end

  def and_i_click_on_confirm
    click_on "Confirm"
  end

  def then_the_mentor_who_was_amended_by_the_provider_is_selected
    expect(page).to have_element(:legend, text: "Which mentors do you want to override the hours for?")
    expect(page).to have_checked_field("James Chess")
    expect(page).to have_unchecked_field("Sarah Doe")
  end

  def when_i_select_both_mentors
    check "Sarah Doe"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_the_hours_page_for_james_chess
    expect(page).to have_h1("How many hours of training did James Chess actually complete?")
    expect(page).to have_content("Hours of training originally claimed: 15")
  end

  def and_the_provider_amendment_is_prefilled
    expect(page).to have_field("Number of hours", with: "11")
    expect(page).to have_field("Why are you overriding this?", with: "Incorrect number of hours")
  end

  def when_i_enter_12_hours_and_a_reason
    fill_in "Number of hours", with: "12"
    fill_in "Why are you overriding this?", with: "School evidence shows 12 hours"
  end

  def then_i_see_the_hours_page_for_sarah_doe
    expect(page).to have_h1("How many hours of training did Sarah Doe actually complete?")
  end

  def when_i_choose_to_remove_all_hours_and_enter_a_reason
    choose "Remove all hours"
    fill_in "Why are you overriding this?", with: "School evidence shows no training"
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_h1("Override the hours of training for this claim")
  end

  def and_i_see_the_overridden_hours
    expect(page).to have_content("James Chess")
    expect(page).to have_content("Sarah Doe")
    expect(page).to have_content("12 hours")
    expect(page).to have_content("0 hours")
  end

  def then_the_clawback_is_requested_with_a_success_message
    expect(page).to have_current_path(claims_support_claims_clawback_path(@claim))
    expect(page).to have_success_banner("Hours of training overridden and clawback requested")
  end

  def and_the_claim_requires_clawback_approval
    expect(@claim.reload).to be_clawback_requires_approval
    expect(@claim.clawback_requested_by).to be_present
  end

  def and_the_hours_are_overridden
    expect(@james_training.reload).to have_attributes(
      not_assured: true,
      hours_clawed_back: 3,
      reason_not_assured: "School evidence shows 12 hours",
      reason_clawed_back: "School evidence shows 12 hours",
    )
    expect(@sarah_training.reload).to have_attributes(
      not_assured: true,
      hours_clawed_back: 10,
      reason_not_assured: "School evidence shows no training",
    )
  end

  def and_the_activity_is_recorded
    expect(Claims::ClaimActivity.where(record: @claim).pluck(:action)).to contain_exactly("amended_by_support", "clawback_requested")
  end

  def when_i_visit_the_override_page_directly
    visit new_override_claims_support_claims_sampling_path(@claim)
  end

  def then_i_am_returned_to_the_claim
    expect(page).to have_current_path(claims_support_claims_sampling_path(@claim))
  end
end
