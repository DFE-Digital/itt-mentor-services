require "rails_helper"

RSpec.describe "Support user approves the clawback requested by another support user",
               service: :claims,
               type: :system do
  include ActionView::Helpers::TextHelper

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_clawback_claim_requiring_approval

    when_i_click_on_the_clawback_claim_requiring_approval
    then_i_see_the_show_page_for_the_clawback_claim
    and_i_see_the_clawback_requires_approval_tag

    when_i_click_on_review_clawback
    then_i_see_the_clawback_approval_form_for_john_doe

    when_i_select_yes
    and_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change
    then_i_see_the_clawback_approval_form_for_john_doe

    when_click_on_continue
    then_i_see_the_check_your_answers_page

    when_click_on_continue
    then_i_see_the_show_page_for_the_clawback_claim
    and_i_see_the_clawback_requested_tag
    and_i_see_a_success_banner
  end

  private

  def given_claims_exist
    @school = create(:claims_school, name: "Hogwarts")
    @support_user = create(:claims_support_user, first_name: "Harry", last_name: "Potter")

    @claim_one = create(:claim,
                        :audit_requested,
                        status: :clawback_requires_approval,
                        reference: 11_111_111,
                        clawback_requested_by: @support_user,
                        school: @school)

    @john_doe = create(:claims_mentor, first_name: "John", last_name: "Doe", schools: [@school])

    @john_doe_training = create(
      :mentor_training,
      :rejected,
      claim: @claim_one,
      mentor: @john_doe,
      hours_completed: 20,
      hours_clawed_back: 7,
      reason_clawed_back: "Mismatch in hours recorded compared with hours claimed.",
    )
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

  def then_i_see_the_clawback_claim_requiring_approval
    expect(page).to have_claim_card({
      "title" => "#{@claim_one.reference} - Hogwarts",
      "url" => "/support/claims/clawbacks/claims/#{@claim_one.id}",
      "status" => "Clawback requires approval",
      "academic_year" => @claim_one.academic_year.name,
      "provider_name" => @claim_one.provider_name,
      "submitted_at" => I18n.l(@claim_one.submitted_at.to_date, format: :long),
      "amount" => Money.new(@school.region.funding_available_per_hour * 20, "GBP").format,
    })
  end

  def when_i_click_on_the_clawback_claim_requiring_approval
    click_on "11111111 - Hogwarts"
  end

  def then_i_see_the_show_page_for_the_clawback_claim
    expect(page).to have_title("Clawbacks - Hogwarts - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_span_caption("Clawbacks - Claim 11111111")
    expect(page).to have_h1("Hogwarts")
    expect(page).not_to have_link("Review clawback", href: "/support/claims/clawbacks/claims/#{@claim_one.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", "Hogwarts")
    expect(page).to have_summary_list_row("Academic year", @claim_one.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @claim_one.provider.name)
    expect(page).to have_h2("Hours of training")
    @claim_one.mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
      within(".govuk-summary-card") do
        expect(page).to have_element(:div, text: mentor_training.mentor.full_name, class: "govuk-summary-card__title-wrapper")
        within(".govuk-summary-card__content") do
          expect(page).to have_summary_list_row("Mentor worked hours", pluralize(mentor_training.corrected_hours_completed, "hour"))
          expect(page).to have_summary_list_row("Original hours claimed", pluralize(mentor_training.hours_completed, "hour"))
          expect(page).to have_summary_list_row("Hours clawed back", pluralize(mentor_training.hours_clawed_back, "hour"))
          expect(page).to have_summary_list_row("Reason for clawback", mentor_training.reason_clawed_back)
        end
      end
    end

    within("#grant_funding") do
      expect(page).to have_h2("Grant funding")
      expect(page).to have_summary_list_row("Original claim amount", @claim_one.amount.format(symbol: true, decimal_mark: ".", no_cents: true))
      expect(page).to have_summary_list_row("Hours clawed back", pluralize(@claim_one.mentor_trainings.sum(:hours_clawed_back), "hour"))
    end
  end

  def and_i_see_the_clawback_requires_approval_tag
    expect(page).to have_tag("Clawback requires approval", "orange")
  end

  def when_i_click_on_review_clawback
    click_on "Review clawback"
  end

  def then_i_see_the_clawback_approval_form_for_john_doe
    expect(page).to have_title(
      "Approve clawback - John Doe - Claim - 11111111 - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_span_caption("Claim - 11111111")
    expect(page).to have_h1("Approve clawback - John Doe")

    expect(page).to have_summary_list_row("Original hours claimed", "20 hours")
    expect(page).to have_summary_list_row("Mentor worked hours", "13 hours")
    expect(page).to have_summary_list_row("Hours clawed back", "7 hours")
    expect(page).to have_summary_list_row(
      "Hourly rate",
      Money.new(@school.region.funding_available_per_hour, "GBP").format,
    )
    expect(page).to have_summary_list_row(
      "Clawback amount",
      Money.new(@school.region.funding_available_per_hour * 7, "GBP").format,
    )
    expect(page).to have_summary_list_row("Provider name", @claim_one.provider_name)
    expect(page).to have_summary_list_row("Provider comments", "Not assured")
    expect(page).to have_summary_list_row("School name", "Hogwarts")
    expect(page).to have_summary_list_row("School comments", "Rejected")
    expect(page).to have_summary_list_row(
      "Reason for clawback",
      "Mismatch in hours recorded compared with hours claimed.",
    )

    expect(page).to have_element(:legend, text: "I confirm that the information for this clawback is correct")
    expect(page).to have_field("Yes", type: :radio)
    expect(page).to have_field("No", type: :radio)
    expect(page).to have_field("If No, please provide a reason", type: :textarea)

    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims/#{@claim_one.id}")
  end

  def when_i_select_yes
    choose "Yes"
  end

  def when_click_on_continue
    click_on "Continue"
  end
  alias_method :and_click_on_continue, :when_click_on_continue

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title(
      "Check your answers - Approve clawback - Claim - 11111111 - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_span_caption("Approve clawback - Claim - 11111111")
    expect(page).to have_h1("Check your answers")

    expect(page).to have_summary_list_row("John Doe", "Approved")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims/#{@claim_one.id}")
  end

  def when_i_click_on_change
    click_on "Change approval for John Doe"
  end

  def and_i_see_the_clawback_requested_tag
    expect(page).to have_tag("Ready for clawback", "turquoise")
  end

  def and_i_see_a_success_banner
    expect(page).to have_success_banner(
      "Clawback approved",
      "This clawback can now be sent to the Payer.",
    )
  end
end
