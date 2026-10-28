require "rails_helper"

RSpec.describe "Support user changes the provider of a claim", service: :claims, type: :system do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  scenario "the claim has been submitted" do
    given_providers_exist
    and_a_submitted_claim_exists
    and_i_am_signed_in

    when_i_visit_the_claim
    then_i_see_the_claim_with_the_old_provider

    when_i_click_change_accredited_provider
    then_i_see_the_provider_page

    when_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_enter_a_provider

    when_i_enter_the_old_provider_name
    and_i_click_on_continue
    and_i_select_the_old_provider
    and_i_click_on_continue
    then_i_see_a_validation_error_that_i_must_select_a_different_provider

    when_i_select_the_new_provider
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_do_not_see_the_audit_warning

    when_i_click_on_change_accredited_provider_button
    then_i_see_the_claim_with_the_new_provider
    and_the_claim_is_still_submitted
    and_no_email_is_sent_to_the_new_provider
  end

  scenario "the claim has been amended by the provider" do
    given_providers_exist
    and_a_claim_amended_by_the_provider_exists
    and_i_am_signed_in

    when_i_visit_the_claim
    then_i_see_the_claim_with_the_old_provider

    when_i_click_change_accredited_provider
    and_i_enter_the_new_provider_name
    and_i_click_on_continue
    and_i_select_the_new_provider
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_the_audit_warning

    when_i_click_on_change_accredited_provider_button
    then_i_see_the_claim_with_the_new_provider
    and_i_see_the_new_provider_has_been_asked_to_audit_the_claim
    and_the_claim_is_audit_requested
    and_an_email_is_sent_to_the_new_provider
  end

  scenario "some mentors have already claimed hours with the new provider" do
    given_providers_exist
    and_a_claim_with_several_mentors_exists
    and_some_mentors_have_already_claimed_hours_with_the_new_provider
    and_i_am_signed_in

    when_i_visit_the_claim
    and_i_click_change_accredited_provider
    and_i_enter_the_new_provider_name
    and_i_click_on_continue
    and_i_select_the_new_provider
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page
    and_i_see_which_mentors_will_be_removed_or_have_their_hours_reduced

    when_i_click_on_change_accredited_provider_button
    then_i_see_the_claim_with_the_new_provider
    and_i_am_told_which_mentors_were_removed_or_had_their_hours_reduced
    and_i_see_the_updated_mentor_hours
  end

  scenario "none of the mentors have hours left with the new provider" do
    given_providers_exist
    and_a_submitted_claim_exists
    and_the_mentor_has_no_hours_left_with_the_new_provider
    and_i_am_signed_in

    when_i_visit_the_claim
    and_i_click_change_accredited_provider
    and_i_enter_the_new_provider_name
    and_i_click_on_continue
    and_i_select_the_new_provider
    and_i_click_on_continue
    then_i_see_a_validation_error_that_no_mentors_have_hours_left
  end

  private

  def given_providers_exist
    @old_provider = create(:claims_provider, name: "Springfield University")
    @new_provider = create(:claims_provider, name: "Shelbyville University")
    @new_provider_user = create(:claims_provider_user, providers: [@new_provider])
  end

  def and_a_submitted_claim_exists
    @claim = create(:claim, :submitted, reference: 11_111_111, provider: @old_provider)
    create(:mentor_training, claim: @claim, provider: @old_provider, hours_completed: 20)
  end

  def and_a_claim_with_several_mentors_exists
    @claim = create(:claim, :submitted, reference: 11_111_111, provider: @old_provider)
    @mentor_james = create(:claims_mentor, first_name: "James", last_name: "Jameson")
    @mentor_barry = create(:claims_mentor, first_name: "Barry", last_name: "Garlow")
    @mentor_anne = create(:claims_mentor, first_name: "Anne", last_name: "Wilson")
    [@mentor_james, @mentor_barry, @mentor_anne].each do |mentor|
      create(:mentor_training, claim: @claim, mentor:, provider: @old_provider, hours_completed: 10)
    end
  end

  def and_some_mentors_have_already_claimed_hours_with_the_new_provider
    claim_hours_with_new_provider(@mentor_barry, 15)
    claim_hours_with_new_provider(@mentor_anne, 20)
  end

  def and_the_mentor_has_no_hours_left_with_the_new_provider
    claim_hours_with_new_provider(@claim.mentor_trainings.first.mentor, 20)
  end

  def and_a_claim_amended_by_the_provider_exists
    @claim = create(
      :claim,
      :submitted,
      reference: 11_111_111,
      provider: @old_provider,
      status: :sampling_provider_not_approved,
      amendment_notification_sent_at: 10.days.ago,
    )
    create(:mentor_training, claim: @claim, provider: @old_provider, hours_completed: 20, not_assured: true, reason_not_assured: "No evidence")
    create(:provider_sampling, provider: @old_provider, claims: [@claim], created_at: 40.days.ago)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_visit_the_claim
    visit claims_support_claim_path(@claim)
  end

  def then_i_see_the_claim_with_the_old_provider
    expect(page).to have_h1(@claim.school_name)
    expect(page).to have_summary_list_row("Accredited provider", "Springfield University")
    expect(page).to have_link("Change Accredited provider")
  end

  def when_i_click_change_accredited_provider
    click_on "Change Accredited provider"
  end
  alias_method :and_i_click_change_accredited_provider, :when_i_click_change_accredited_provider

  def then_i_see_the_provider_page
    expect(page).to have_title(
      "Enter the new accredited provider - Claim 11111111 - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_span_caption("Claim 11111111")
    expect(page).to have_element(:label, text: "Enter the new accredited provider")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: claims_support_claim_path(@claim))
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_a_validation_error_that_i_must_enter_a_provider
    expect(page).to have_validation_error("Enter a provider name, United Kingdom provider number (UKPRN), unique reference number (URN) or postcode")
  end

  def when_i_enter_the_old_provider_name
    fill_in "Enter the new accredited provider", with: "University"
  end

  def and_i_enter_the_new_provider_name
    fill_in "Enter the new accredited provider", with: "Shelbyville"
  end

  def and_i_select_the_old_provider
    choose "Springfield University"
  end

  def then_i_see_a_validation_error_that_i_must_select_a_different_provider
    expect(page).to have_validation_error("Select a different accredited provider")
  end

  def when_i_select_the_new_provider
    choose "Shelbyville University"
  end
  alias_method :and_i_select_the_new_provider, :when_i_select_the_new_provider

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Claim 11111111 - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_span_caption("Claim 11111111")
    expect(page).to have_h1("Check your answers")
    expect(page).to have_summary_list_row("Current accredited provider", "Springfield University")
    expect(page).to have_summary_list_row("New accredited provider", "Shelbyville University")
    expect(page).to have_button("Change accredited provider")
  end

  def and_i_do_not_see_the_audit_warning
    expect(page).not_to have_warning_text("Shelbyville University will be emailed")
  end

  def and_i_see_the_audit_warning
    expect(page).to have_warning_text(
      "Shelbyville University will be emailed and asked to audit this claim. " \
      "The claim will be set to audit requested and the provider will have 30 days to respond.",
    )
  end

  def and_i_see_which_mentors_will_be_removed_or_have_their_hours_reduced
    expect(page).to have_h2("Changes to mentors")
    expect(page).to have_summary_list_row("Anne Wilson", "Removed from the claim (no hours left to claim with Shelbyville University)")
    expect(page).to have_summary_list_row("Barry Garlow", "Hours reduced from 10 to 5")
    expect(page).not_to have_element(:dt, text: "James Jameson", class: "govuk-summary-list__key")
  end

  def then_i_see_a_validation_error_that_no_mentors_have_hours_left
    expect(page).to have_validation_error("None of the mentors on this claim have hours left to claim with Shelbyville University")
  end

  def when_i_click_on_change_accredited_provider_button
    click_on "Change accredited provider"
  end

  def then_i_see_the_claim_with_the_new_provider
    expect(page).to have_current_path(claims_support_claim_path(@claim))
    expect(page).to have_success_banner("Accredited provider changed")
    expect(page).to have_summary_list_row("Accredited provider", "Shelbyville University")
  end

  def and_i_am_told_which_mentors_were_removed_or_had_their_hours_reduced
    expect(page).to have_success_banner(
      "Accredited provider changed",
      "Anne Wilson has been removed from the claim. Barry Garlow’s hours have been reduced to 5.",
    )
  end

  def and_i_see_the_updated_mentor_hours
    expect(page).to have_summary_list_row("James Jameson", "10 hours")
    expect(page).to have_summary_list_row("Barry Garlow", "5 hours")
    expect(page).not_to have_element(:dt, text: "Anne Wilson", class: "govuk-summary-list__key")
  end

  def and_the_claim_is_still_submitted
    expect(page).to have_tag("Submitted", "teal")
  end

  def and_no_email_is_sent_to_the_new_provider
    expect(audit_email).to be_nil
  end

  def and_i_see_the_new_provider_has_been_asked_to_audit_the_claim
    expect(page).to have_success_banner(
      "Accredited provider changed",
      "Shelbyville University has been emailed and asked to audit this claim",
    )
  end

  def and_the_claim_is_audit_requested
    expect(page).to have_tag("Audit requested", "yellow")
  end

  def and_an_email_is_sent_to_the_new_provider
    expect(audit_email).not_to be_nil
  end

  def audit_email
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(@new_provider_user.email) && delivery.subject == "ITT mentor claims need to be audited"
    end
  end

  def claim_hours_with_new_provider(mentor, hours_completed)
    other_claim = create(:claim, :submitted, provider: @new_provider)
    create(:mentor_training, claim: other_claim, mentor:, provider: @new_provider, hours_completed:)
  end
end
