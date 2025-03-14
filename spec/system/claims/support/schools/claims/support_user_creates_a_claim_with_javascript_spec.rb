require "rails_helper"

RSpec.describe "School user creates a claim with javascript disabled", service: :claims, type: :system do
  scenario do
    given_an_claim_window_exists
    and_a_school_exists
    and_providers_exist
    and_i_am_signed_in
    when_i_click_on_the_school
    and_i_navigate_to_claims
    and_i_click_on_add_claim
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

    when_i_click_on_save_claim
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
      name: "London School",
      mentors: [@mentor_1, @mentor_2, @mentor_3],
      region: regions(:inner_london),
    )
  end

  def and_providers_exist
    @niot_provider = create(:provider, :niot)
    @bpn_provider = create(:provider, :best_practice_network)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_click_on_the_school
    click_on "London School"
  end

  def and_i_navigate_to_claims
    within(secondary_navigation) do
      click_on "Claims"
    end
  end

  def and_i_click_on_add_claim
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
      text: "Add claim",
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
    expect(page).to have_element(:span, text: "Add claim", class: "govuk-caption-l")
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
    expect(page).to have_element(:span, text: "Add claim", class: "govuk-caption-l")
    expect(page).to have_h1("Mentors for Best Practice Network", class: "govuk-heading-l")

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
    expect(page).to have_element(
      :span,
      text: "Add claim - #{@school.name} - Best Practice Network",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Hours of training for Joe Bloggs", class: "govuk-heading-l")

    expect(page).to have_field("20 hours", type: :radio)
    expect(page).to have_field("Another amount", type: :radio)
  end

  def when_i_choose_20_hours
    choose "20 hours"
  end

  def then_i_see_the_mentor_training_hours_step_for_sarah_doe
    expect(page).to have_element(
      :span,
      text: "Add claim - #{@school.name} - Best Practice Network",
      class: "govuk-caption-l",
    )
    expect(page).to have_h1("Hours of training for Sarah Doe", class: "govuk-heading-l")

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
    expect(page).to have_summary_list_row("Accredited provider", "Best Practice Network")
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

  def when_i_click_on_save_claim
    click_on "Save claim"
  end

  def then_i_see_the_claim_has_been_successfully_created
    expect(page).to have_success_banner("Claim added")

    claim = Claims::Claim.draft.order(:submitted_at).last
    expect(page).to have_table_row({
      "Claim reference" => claim.reference,
      "Accredited provider" => "Best Practice Network",
      "Mentors" => "Joe Bloggs Sarah Doe",
      "Claim amount" => "£1,393.60",
      "Date submitted" => "-",
      "Status" => "Draft",
    })
  end
end
