require "rails_helper"

RSpec.describe "Support user edits a mentor training for a clawback request", service: :claims, type: :system do
  include ActionView::Helpers::TextHelper

  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_one
    then_i_see_the_show_page_for_claim_one

    when_i_click_on_the_change_link_for_clawback_reason
    then_i_see_the_clawback_step_for_claim_one

    when_i_click_on_back
    then_i_see_the_show_page_for_claim_one

    when_i_click_on_the_change_link_for_clawback_reason
    then_i_see_the_clawback_step_for_claim_one

    when_i_enter_more_hours_than_the_mentor_has_hours_completed
    and_i_click_on_continue
    then_i_see_a_validation_error_for_entering_too_many_hours

    when_i_enter_valid_data
    and_i_click_on_continue
    then_i_see_a_success_message
    and_i_see_the_updated_show_page_for_claim_one
  end

  private

  def given_claims_exist
    @claim_one = create(:claim,
                        :submitted,
                        status: :clawback_requested,
                        reference: 11_111_111)

    @john_doe = create(:claims_mentor, first_name: "John", last_name: "Doe")
    @sarah_jane = create(:claims_mentor, first_name: "Sarah", last_name: "Jane")

    @john_doe_training = create(:mentor_training, claim: @claim_one, mentor: @john_doe,
                                                  hours_completed: 20, not_assured: true,
                                                  hours_clawed_back: 7,
                                                  reason_not_assured: "Mismatch in hours recorded compared with hours claimed.",
                                                  reason_clawed_back: "Mismatch in hours recorded compared with hours claimed.")
    @sarah_jane_training = create(:mentor_training, claim: @claim_one, mentor: @sarah_jane,
                                                    hours_completed: 15, not_assured: true,
                                                    hours_clawed_back: 5,
                                                    reason_not_assured: "Mismatch in hours recorded compared with hours claimed.",
                                                    reason_clawed_back: "Mismatch in hours recorded compared with hours claimed.")
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

  def and_i_click_on_claim_one
    click_on "11111111 - #{@claim_one.school_name}"
  end

  def then_i_see_the_show_page_for_claim_one
    expect(page).to have_title("Clawbacks - #{@claim_one.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1(@claim_one.school_name)
    expect(page).to have_element(:strong, text: "Ready for clawback", class: "govuk-tag govuk-tag--turquoise")
    expect(page).not_to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@claim_one.id}", class: "govuk-link govuk-button")
    expect(page).to have_summary_list_row("School", @claim_one.school_name)
    expect(page).to have_summary_list_row("Academic year", @claim_one.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @claim_one.provider.name)
    expect(page).to have_h2("Hours of training")
    @claim_one.mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
      within("#mentor-training-#{mentor_training.id}") do
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
    end

    within("#grant_funding") do
      expect(page).to have_h2("Grant funding")
      expect(page).to have_summary_list_row("Original claim amount", @claim_one.amount.format(symbol: true, decimal_mark: ".", no_cents: true))
      expect(page).to have_summary_list_row("Hours clawed back", pluralize(@claim_one.mentor_trainings.sum(:hours_clawed_back), "hour"))
    end
  end
  alias_method :and_i_see_the_show_page_for_claim_one, :then_i_see_the_show_page_for_claim_one

  def when_i_click_on_the_change_link_for_clawback_reason
    click_on "Change John Doe Mentor worked hours"
  end

  def then_i_see_the_clawback_step_for_claim_one
    expect(page).to have_title("Clawback details for #{@john_doe.full_name} - #{@claim_one.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours the mentor worked", class: "govuk-label")
    expect(page).to have_element(:div, text: "John Doe's original claim was for #{@john_doe_training.hours_completed} hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Notes on your decision", class: "govuk-label")
    expect(page).to have_element(:div, text: "Only include details related to #{@john_doe.full_name}", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims/#{@claim_one.id}")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def when_i_enter_more_hours_than_the_mentor_has_hours_completed
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[number_of_hours]", with: 30
  end

  def and_i_click_on_continue
    click_on "Continue"
  end

  def then_i_see_a_validation_error_for_entering_too_many_hours
    expect(page).to have_validation_error("must be less than #{@john_doe_training.hours_completed}")
  end

  def when_i_enter_a_valid_number_of_hours
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[number_of_hours]", with: 20
  end

  def when_i_enter_valid_data
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[number_of_hours]", with: 2
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[reason_for_clawback]", with: "Insufficient evidence."
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner("Clawback updated")
  end

  def and_i_see_the_updated_show_page_for_claim_one
    expect(page).to have_h2("Hours of training")
    @claim_one.mentor_trainings.not_assured.order_by_mentor_full_name.each do |mentor_training|
      within("#mentor-training-#{mentor_training.id}") do
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
    end
  end
end
