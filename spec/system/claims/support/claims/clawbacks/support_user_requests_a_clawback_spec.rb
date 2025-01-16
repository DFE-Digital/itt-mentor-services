require "rails_helper"

RSpec.describe "Support user requests a clawback on a claim", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    and_i_click_on_claim_one
    then_i_see_the_show_page_for_claim_one

    when_i_click_on_request_clawback
    then_i_see_the_clawback_details_page_for_jane_smith

    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_entering_hours
    and_i_see_validation_error_for_not_entering_notes

    when_i_enter_fifty_hours
    and_i_click_on_continue
    then_i_see_a_validation_error_when_entering_too_many_hours_for_jane_smith

    when_i_enter_valid_data
    and_i_click_on_continue
    then_i_see_the_clawback_details_page_for_john_doe

    when_i_enter_valid_data
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_change
    then_i_see_the_clawback_details_page_for_jane_smith

    when_i_click_on_continue
    then_i_see_the_clawback_details_page_for_john_doe

    when_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_request_clawback
    then_i_see_a_success_message
    and_i_see_the_clawbacks_index_page
    and_i_see_the_claim_status_is_clawback_requested

    when_i_click_on_claim_one
    then_i_do_not_see_the_request_clawback_button
  end

  private

  def given_claims_exist
    @claim_one = create(:claim,
                        :submitted,
                        status: :sampling_not_approved,
                        reference: 11_111_111)

    @john_doe = create(:claims_mentor, first_name: "John", last_name: "Doe")
    @jane_smith = create(:claims_mentor, first_name: "Jane", last_name: "Smith")

    @john_doe_training = create(:mentor_training, claim: @claim_one, mentor: @john_doe,
                                                  hours_completed: 20, not_assured: true,
                                                  reason_not_assured: "Mismatch in hours recorded compared with hours claimed.")
    @jane_smith_training = create(:mentor_training, claim: @claim_one, mentor: @jane_smith,
                                                    hours_completed: 20, not_assured: true,
                                                    reason_not_assured: "Mismatch in hours recorded compared with hours claimed.")
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
    expect(page).to have_element(:strong, text: "Claim not approved", class: "govuk-tag govuk-tag--turquoise")
    expect(page).to have_link("Request clawback", href: "/support/claims/clawbacks/claims/new/#{@claim_one.id}")
    expect(page).to have_summary_list_row("School", @claim_one.school_name)
    expect(page).to have_summary_list_row("Academic year", @claim_one.academic_year_name)
    expect(page).to have_summary_list_row("Accredited provider", @claim_one.provider.name)
    expect(page).to have_summary_list_row("Mentors") do |row|
      @claim_one.mentors.each do |mentor|
        expect(row).to have_css("ul.govuk-list li", text: mentor.full_name)
      end
    end
    expect(page).to have_h2("Hours of training")
    @claim_one.mentor_trainings.order_by_mentor_full_name.each do |mentor_training|
      expect(page).to have_summary_list_row(mentor_training.mentor.full_name, "#{mentor_training.hours_completed} hours")
    end
    expect(page).to have_h2("Grant funding")
    expect(page).to have_summary_list_row("Total hours", "#{@claim_one.mentor_trainings.sum(:hours_completed)} hours")
    expect(page).to have_summary_list_row("Hourly rate", @claim_one.school.region.funding_available_per_hour)
    expect(page).to have_summary_list_row("Claim amount", @claim_one.amount.format(symbol: true, decimal_mark: ".", no_cents: true))
  end

  def when_i_click_on_request_clawback
    click_on "Request clawback"
  end

  def then_i_see_the_clawback_details_page_for_jane_smith
    expect(page).to have_title("Clawback details for Jane Smith - #{@claim_one.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours to clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Enter whole numbers up to a maximum of 20 hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Notes on your decision", class: "govuk-label")
    expect(page).to have_element(:div, text: "Only include details related to Jane Smith", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def then_i_see_the_clawback_details_page_for_john_doe
    expect(page).to have_title("Clawback details for John Doe - #{@claim_one.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")

    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Clawback details")
    expect(page).to have_element(:label, text: "Number of hours to clawback", class: "govuk-label")
    expect(page).to have_element(:div, text: "Enter whole numbers up to a maximum of 20 hours", class: "govuk-hint")
    expect(page).to have_element(:label, text: "Notes on your decision", class: "govuk-label")
    expect(page).to have_element(:div, text: "Only include details related to John Doe", class: "govuk-hint")
    expect(page).to have_button("Continue")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def when_i_enter_fifty_hours
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[number_of_hours]", with: 50
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue, :and_i_click_on_continue

  def then_i_see_a_validation_error_for_not_entering_hours
    expect(page).to have_validation_error("Enter the number of hours to clawback")
  end

  def and_i_see_validation_error_for_not_entering_notes
    expect(page).to have_validation_error("Enter the details about your decision.")
  end

  def then_i_see_a_validation_error_when_entering_too_many_hours_for_jane_smith
    expect(page).to have_validation_error("must be less than or equal to 20")
  end

  def when_i_enter_valid_data
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[number_of_hours]", with: "8"
    fill_in "claims_request_clawback_wizard_mentor_training_clawback_step[reason_for_clawback]", with: "Mismatch in hours recorded compared with hours claimed."
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_title("Check your answers - #{@claim_one.school_name} - Claim 11111111 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_element(:span, text: "Clawbacks - Claim 11111111", class: "govuk-caption-l")
    expect(page).to have_h1("Check your answers")
    within "#clawback-totals" do
      expect(page).to have_summary_list_row("Number of hours", "16")
      expect(page).to have_summary_list_row("Hourly rate", @claim_one.school.region.funding_available_per_hour)
      expect(page).to have_summary_list_row("Clawback amount", "£#{@claim_one.school.region.funding_available_per_hour * 16}")
    end

    within "#mentor-training-#{@john_doe_training.id}" do
      expect(page).to have_summary_list_row("Number of hours", "8")
      expect(page).to have_summary_list_row("Hourly rate", @claim_one.school.region.funding_available_per_hour)
      expect(page).to have_summary_list_row("Clawback amount", "£#{@claim_one.school.region.funding_available_per_hour * 8}")
    end

    within "#mentor-training-#{@john_doe_training.id}" do
      expect(page).to have_summary_list_row("Number of hours", "8")
      expect(page).to have_summary_list_row("Hourly rate", @claim_one.school.region.funding_available_per_hour)
      expect(page).to have_summary_list_row("Clawback amount", "£#{@claim_one.school.region.funding_available_per_hour * 8}")
    end

    expect(page).to have_element(:strong, text: "We will show clawback details to the school.", class: "govuk-warning-text__text")
    expect(page).to have_button("Request clawback")
    expect(page).to have_link("Cancel", href: "/support/claims/clawbacks/claims")
  end

  def when_i_click_on_change
    first("a", text: "Change").click
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner("Clawback requested")
  end

  def and_i_see_the_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
  end

  def and_i_see_the_claim_status_is_clawback_requested
    expect(page).to have_claim_card({
      "title" => "#{@claim_one.reference} - #{@claim_one.school_name}",
      "url" => "/support/claims/clawbacks/claims/#{@claim_one.id}",
      "status" => "Clawback requested",
      "academic_year" => @claim_one.academic_year.name,
      "provider_name" => @claim_one.provider.name,
      "submitted_at" => I18n.l(@claim_one.submitted_at.to_date, format: :long),
      "amount" => @claim_one.amount.format(symbol: true, decimal_mark: ".", no_cents: true),
    })
  end

  def when_i_click_on_claim_one
    click_on "11111111 - #{@claim_one.school_name}"
  end

  def then_i_do_not_see_the_request_clawback_button
    expect(page).not_to have_link("Request clawback")
  end
end
