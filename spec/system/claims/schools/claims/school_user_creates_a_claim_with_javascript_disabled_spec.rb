require "rails_helper"

RSpec.describe "School user creates a claim with javascript disabled", service: :claims, type: :system do
  scenario do
    given_an_claim_window_exists
    and_a_school_exists
    and_providers_exist
    and_i_am_signed_in
    when_i_click_on_add_claim
    then_i_see_the_enter_a_provider_step

    when_i_enter_the_provider_name
    and_i_click_on_continue
    then_i_see_the_provider_options_step
    and_i_see_a_radio_button_for_best_practice_network
    and_i_do_not_see_a_radio_button_for_niot

    when_i_select_best_practice_network
    and_i_click_on_continue
    then_i_see_the_mentor_selection_step

    when_i_select_joe_bloggs
    and_i_select_sarah_doe
    and_i_click_on_continue
    then_i_see_the_mentor_training_hours_step_for_joe_bloggs

    when_i_choose_20_hours
    and_i_click_on_continue
    then_i_see_the_mentor_training_hours_step_for_sarah_doe

    when_i_choose_another_amount
    and_enter_6_hours
    and_i_click_on_continue
    then_i_see_the_check_your_answers_page

    when_i_click_on_submit_claim
    then_i_see_the_claim_has_been_successfully_created
  end

  private

  def given_an_claim_window_exists
    @claim_window = create(:claim_window, :current)
    @academic_year = @claim_window.academic_year
  end

  def and_a_school_exists
    @mentor_1 = build(:claims_mentor, first_name: "Joe", last_name: "Bloggs")
    @mentor_2 = build(:claims_mentor, first_name: "Sarah", last_name: "Doe")
    @mentor_3 = build(:claims_mentor, first_name: "John", last_name: "Smith")

    @school = create(
      :claims_school,
      mentors: [@mentor_1, @mentor_2, @mentor_3],
      region: regions(:inner_london),
    )
  end

  def and_providers_exist
    @niot_provider = create(:provider, :niot)
    @bpn_provider = create(:provider, :best_practice_network)
  end

  def and_i_am_signed_in
    @user = create(:claims_user, schools: [@school])
    sign_in_as(@user)
  end

  def when_i_click_on_add_claim
    click_on "Add claim"
  end

  def then_i_see_the_enter_a_provider_step
    expect(page).to have_element(
      :label,
      text: "Enter the accredited provider for this claim",
      class: "govuk-label govuk-label--l",
    )
    expect(page).to have_element(
      :span,
      text: "Claim details",
      class: "govuk-caption-l",
    )
    expect(page).to have_button("Continue")
  end

  def when_i_enter_the_provider_name
    fill_in "Enter the accredited provider for this claim", with: "Best Practice Network"
  end

  def and_i_click_on_continue
    click_on "Continue"
  end
  alias_method :when_i_click_on_continue,
               :and_i_click_on_continue

  def then_i_see_the_provider_options_step
    expect(page).to have_element(:span, text: "Claim details", class: "govuk-caption-l")
    expect(page).to have_element(
      :h1,
      text: "1 results found for 'Best Practice Network'",
      class: "govuk-fieldset__heading",
    )
  end

  def and_i_see_a_radio_button_for_best_practice_network
    expect(page).to have_field("Best Practice Network", type: :radio)
  end

  def and_i_do_not_see_a_radio_button_for_niot
    expect(page).not_to have_field(
      "NIoT: National Institute of Teaching, founded by the School-Led Development Trust",
      type: :radio,
    )
  end

  def when_i_select_best_practice_network
    choose "Best Practice Network"
  end

  def then_i_see_the_mentor_selection_step
    expect(page).to have_element(:span, text: "Claim details", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "Select mentors that trained with Best Practice Network", class: "govuk-fieldset__heading")

    expect(page).to have_field("Joe Bloggs", type: :checkbox)
    expect(page).to have_field("John Smith", type: :checkbox)
    expect(page).to have_field("Sarah Doe", type: :checkbox)
  end

  def when_i_select_joe_bloggs
    check "Joe Bloggs"
  end

  def and_i_select_sarah_doe
    check "Sarah Doe"
  end

  def then_i_see_the_mentor_training_hours_step_for_joe_bloggs
    expect(page).to have_element(:span, text: "Claim details - Best Practice Network", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "How many hours of training did Joe Bloggs complete?", class: "govuk-fieldset__heading")

    expect(page).to have_field("20 hours", type: :radio)
    expect(page).to have_field("Another amount", type: :radio)
  end

  def when_i_choose_20_hours
    choose "20 hours"
  end

  def then_i_see_the_mentor_training_hours_step_for_sarah_doe
    expect(page).to have_element(:span, text: "Claim details - Best Practice Network", class: "govuk-caption-l")
    expect(page).to have_element(:h1, text: "How many hours of training did Sarah Doe complete?", class: "govuk-fieldset__heading")

    expect(page).to have_field("20 hours", type: :radio)
    expect(page).to have_field("Another amount", type: :radio)
  end

  def when_i_choose_another_amount
    choose "Another amount"
  end

  def and_enter_6_hours
    fill_in "Number of hours", with: 6
  end

  def then_i_see_the_check_your_answers_page
    expect(page).to have_h1("Check your answers", class: "govuk-heading-l")

    expect(page).to have_summary_list_row("Academic year", @academic_year.name)
    expect(page).to have_summary_list_row("Provider", "Best Practice Network")
    expect(page).to have_summary_list_row(
      "Mentors",
      "Joe Bloggs Sarah Doe",
    )

    expect(page).to have_h2("Hours of training", class: "govuk-heading-m")

    expect(page).to have_summary_list_row("Joe Bloggs", "20 hours")
    expect(page).to have_summary_list_row("Sarah Doe", "6 hours")

    expect(page).to have_h2("Grant funding", class: "govuk-heading-m")

    expect(page).to have_summary_list_row("Total hours", "26 hours")
    expect(page).to have_summary_list_row("Hourly rate", "£53.60")
    expect(page).to have_summary_list_row("Claim amount", "£1,393.60")
  end

  def when_i_click_on_submit_claim
    click_on "Accept and submit"
  end

  def then_i_see_the_claim_has_been_successfully_created
    expect(page).to have_element(:h1, text: "Claim submitted", class: "govuk-panel__title")

    claim = Claims::Claim.submitted.order(:submitted_at).last

    expect(page).to have_element(
      :div,
      text: "Your reference number\n#{claim.reference}",
      class: "govuk-panel__body",
    )

    expect(page).to have_element(
      :p,
      text: "We have sent a copy of your claim to best_practice_network@example.com",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :h2,
      text: "What happens next",
      class: "govuk-heading-m",
    )
    expect(page).to have_element(
      :p,
      text: "You will automatically receive your payment from September #{Claims::ClaimWindow.current.academic_year.ends_on&.year}.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Academies and independent schools will receive the payment directly. Maintained schools payments are made to their local authority.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "If we need further information to process your claim we will email you.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :h2,
      text: "We may check your claim",
      class: "govuk-heading-m",
    )
    expect(page).to have_element(
      :p,
      text: "After payment we may check your claim to ensure it is accurate.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :p,
      text: "Best Practice Network will contact you if your claim undergoes a check.",
      class: "govuk-body",
    )
    expect(page).to have_element(
      :a,
      text: "What do you think of this service? Takes 30 seconds (opens in a new tab)",
      class: "govuk-link",
    )
  end
end
