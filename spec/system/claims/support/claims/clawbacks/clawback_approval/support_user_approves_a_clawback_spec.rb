require "rails_helper"

RSpec.describe "Support user approves a clawback", service: :claims, type: :system do
  scenario do
    given_a_claim_requiring_clawback_approval_exists
    and_i_am_signed_in

    when_i_view_the_claim
    and_i_click_on_review_clawback
    then_i_see_a_card_for_each_altered_mentor
    and_i_do_not_see_a_card_for_the_unaltered_mentor
    and_i_see_the_summary_of_the_clawback
    and_i_see_the_approve_button

    when_i_click_on_approve_clawback
    then_the_clawback_is_approved
  end

  scenario "the support user who requested the clawback approves it" do
    given_a_claim_requiring_clawback_approval_exists
    and_i_am_signed_in
    and_i_requested_the_clawback

    when_i_view_the_claim
    and_i_click_on_review_clawback
    and_i_click_on_approve_clawback
    then_the_clawback_is_approved
  end

  private

  def given_a_claim_requiring_clawback_approval_exists
    @school = create(:claims_school, name: "Hogwarts")
    @claim = create(:claim, :audit_requested, status: :clawback_requires_approval, reference: 11_111_111, school: @school)

    @john_doe = create(:claims_mentor, first_name: "John", last_name: "Doe", schools: [@school])
    @jane_roe = create(:claims_mentor, first_name: "Jane", last_name: "Roe", schools: [@school])

    @john_doe_training = create(:mentor_training,
                                claim: @claim,
                                mentor: @john_doe,
                                hours_completed: 20,
                                hours_clawed_back: 7,
                                not_assured: true,
                                reason_not_assured: "Only 13 hours worked",
                                reason_clawed_back: "Only 13 hours worked")
    @jane_roe_training = create(:mentor_training, claim: @claim, mentor: @jane_roe, hours_completed: 6)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def and_i_requested_the_clawback
    @claim.update!(clawback_requested_by: @current_user)
  end

  def when_i_view_the_claim
    visit claims_support_claims_clawback_path(@claim)
  end

  def and_i_click_on_review_clawback
    click_on "Review clawback"
  end

  def then_i_see_a_card_for_each_altered_mentor
    expect(page).to have_title("Review clawback - Claim - 11111111 - Claim funding for mentor training - GOV.UK")
    expect(page).to have_span_caption("Claim - 11111111")
    expect(page).to have_h1("Review clawback")

    within("#mentor-training-#{@john_doe_training.id}") do
      expect(page).to have_element(:div, text: "John Doe", class: "govuk-summary-card__title-wrapper")
      expect(page).to have_summary_list_row("Original hours claimed", "20 hours")
      expect(page).to have_summary_list_row("Mentor worked hours", "13 hours")
      expect(page).to have_summary_list_row("Hours clawed back", "7 hours")
      expect(page).to have_summary_list_row("Hourly rate", Money.new(@school.region.funding_available_per_hour, "GBP").format)
      expect(page).to have_summary_list_row("Clawback amount", Money.new(@school.region.funding_available_per_hour * 7, "GBP").format)
      expect(page).to have_summary_list_row("Reason for clawback", "Only 13 hours worked")
    end
  end

  def and_i_do_not_see_a_card_for_the_unaltered_mentor
    expect(page).not_to have_content("Jane Roe")
  end

  def and_i_see_the_summary_of_the_clawback
    within("#clawback_summary") do
      expect(page).to have_h2("Summary")
      expect(page).to have_summary_list_row("Original claim amount", @claim.amount.format(symbol: true, decimal_mark: ".", no_cents: true))
      expect(page).to have_summary_list_row("Hours clawed back", "7 hours")
      expect(page).to have_summary_list_row("Clawback amount", @claim.total_clawback_amount.format(symbol: true, decimal_mark: ".", no_cents: true))
      expect(page).to have_summary_list_row("Adjusted grant funding total", @claim.amount_after_clawback.format(symbol: true, decimal_mark: ".", no_cents: true))
    end
  end

  def and_i_see_the_approve_button
    expect(page).not_to have_field("No", type: :radio)
    expect(page).to have_button("Approve clawback")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims/#{@claim.id}")
  end

  def when_i_click_on_approve_clawback
    click_on "Approve clawback"
  end
  alias_method :and_i_click_on_approve_clawback, :when_i_click_on_approve_clawback

  def then_the_clawback_is_approved
    expect(page).to have_current_path(claims_support_claims_clawback_path(@claim))
    expect(page).to have_tag("Ready for clawback", "teal")
    expect(page).to have_success_banner("Clawback approved", "This clawback can now be sent to the Payer.")
    expect(@claim.reload).to have_attributes(status: "clawback_requested", clawback_approved_by: @current_user)
  end
end
