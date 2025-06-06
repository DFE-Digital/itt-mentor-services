require "rails_helper"

RSpec.describe "School user converts their potential primary and secondary placements",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_subjects_exist
    and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    and_i_am_signed_in
    and_i_see_the_placements_index_page
    and_i_see_the_schools_potential_placement_details
    and_i_see_my_hosting_interest_is_may_offer_placements

    when_i_click_on_add_you_placements
    then_i_see_the_convert_current_information_page

    when_i_click_on_continue
    then_i_see_a_validation_error_for_not_selecting_whether_to_convert_potential_placement_information

    when_i_select_yes_i_will_select_the_potential_placements_i_want_to_convert
    and_i_click_on_continue
    then_i_see_the_select_placement_page
    and_i_see_the_year_groups_set_in_the_potential_placement_details
    and_i_see_the_subjects_set_in_the_potential_placement_details

    when_i_click_on_back
    then_i_see_the_convert_current_information_page

    when_i_click_on_continue
    then_i_see_the_select_placement_page
    and_i_see_the_year_groups_set_in_the_potential_placement_details
    and_i_see_the_subjects_set_in_the_potential_placement_details

    and_i_click_on_publish_placements
    then_i_see_a_validation_error_for_not_selecting_a_primary_placement
    and_i_see_a_validation_error_for_not_selecting_a_secondary_placement

    when_i_select_year_2
    and_i_select_science
    and_i_click_on_publish_placements
    then_i_see_the_placements_index_page
    and_i_see_my_information_was_added_successfully
    and_i_see_my_hosting_interest_is_placements_available
    and_i_see_1_placements_for_primary_year_2
    and_i_see_2_placements_for_secondary_science
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary", code: "00")

    @english = create(:subject, :secondary, name: "English")
    @mathematics = create(:subject, :secondary, name: "Mathematics")
    @science = create(:subject, :secondary, name: "Science")
  end

  def and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    potential_placement_details = {
      "phase" => { "phases" => %w[Primary Secondary] },
      "note_to_providers" => { "note" => "Interested in offering placements at the provider's request" },
      "year_group_selection" => { "year_groups" => %w[year_2 year_3] },
      "secondary_subject_selection" => { "subject_ids" => [@english.id, @science.id] },
      "secondary_placement_quantity" => { "english" => 1, "science" => 2 },
      "year_group_placement_quantity" => { "year_2" => 1, "year_3" => 2 },
    }
    @hosting_interest = build(
      :hosting_interest,
      academic_year: @next_academic_year,
      appetite: "interested",
    )
    @school = create(:placements_school, hosting_interests: @hosting_interest, potential_placement_details:)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def and_i_see_the_schools_potential_placement_details
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(page).to have_h1("Placements you may be able to offer", class: "govuk-heading-l")
    expect(page).to have_h2("Your potential placements", class: "govuk-heading-m")

    expect(page).to have_element(:h3, text: "Education phases", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Potential phases", "Primary Secondary")

    expect(page).to have_element(:h3, text: "Potential primary placements", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Year group", "Number of placements")
    expect(page).to have_summary_list_row("Year 2", "1")
    expect(page).to have_summary_list_row("Year 3", "2")

    expect(page).to have_element(:h3, text: "Potential secondary placements", class: "govuk-heading-s")
    expect(page).to have_summary_list_row("Subject", "Number of placements")
    expect(page).to have_summary_list_row("English", "1")
    expect(page).to have_summary_list_row("Science", "2")

    expect(page).to have_element(:h3, text: "Additional information", class: "govuk-heading-s")
    expect(page).to have_summary_list_row(
      "Message to providers",
      "Interested in offering placements at the provider's request",
    )
  end

  def when_i_click_on_add_you_placements
    click_on "add your placements"
  end

  def then_i_see_the_convert_current_information_page
    expect(page).to have_title(
      "Would you like to convert any of your current information? - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Placement details")
    expect(page).to have_element(
      :legend,
      text: "Would you like to convert any of your current information?",
      class: "govuk-fieldset__legend govuk-fieldset__legend--l",
    )
    expect(page).to have_hint("You can add or edit placements any time after publishing them.")

    expect(page).to have_field("Yes, I will select the potential placements I want to convert", type: :radio)
    expect(page).to have_field("No, I will manually add the placements I can offer", type: :radio)

    expect(page).to have_button("Continue")

    expect(page).to have_link("Cancel", href: placements_school_placements_path(@school))
  end

  def when_i_select_yes_i_will_select_the_potential_placements_i_want_to_convert
    choose "Yes, I will select the potential placements I want to convert"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue, :when_i_click_on_continue

  def then_i_see_the_select_placement_page
    expect(page).to have_title(
      "Select the placements you can offer - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Placement details")
    expect(page).to have_h1("Select the placements you can offer")
    expect(page).to have_paragraph(
      "Select all that apply from your current information about potential placements. Provider will see you have available placements at your school.",
    )
    expect(page).to have_paragraph(
      "You can add or edit placements any time after publishing them.",
    )
  end

  def and_i_see_the_year_groups_set_in_the_potential_placement_details
    expect(page).to have_element(
      :legend,
      text: "Primary placements",
      class: "govuk-fieldset__legend govuk-fieldset__legend--m",
    )

    expect(page).to have_field("Year 2", type: :checkbox)
    expect(
      page.find(
        "#placements-convert-potential-placement-wizard-select-placement-step-year-groups-year-2-hint",
      ).text,
    ).to eq("1 placement")

    expect(page).to have_field("Year 3", type: :checkbox)
    expect(
      page.find(
        "#placements-convert-potential-placement-wizard-select-placement-step-year-groups-year-3-hint",
      ).text,
    ).to eq("2 placements")
  end

  def and_i_see_the_subjects_set_in_the_potential_placement_details
    expect(page).to have_element(
      :legend,
      text: "Secondary placements",
      class: "govuk-fieldset__legend govuk-fieldset__legend--m",
    )

    expect(page).to have_field("English", type: :checkbox)
    expect(
      page.find(
        "#placements-convert-potential-placement-wizard-select-placement-step-subject-ids-#{@english.id}-hint",
      ).text,
    ).to eq("1 placement")

    expect(page).to have_field("Science", type: :checkbox)
    expect(
      page.find(
        "#placements-convert-potential-placement-wizard-select-placement-step-subject-ids-#{@science.id}-hint",
      ).text,
    ).to eq("2 placements")
  end

  def when_i_select_year_2
    check "Year 2"
  end

  def and_i_select_science
    check "Science"
  end

  def and_i_click_on_publish_placements
    click_on "Publish placements"
  end

  def then_i_see_a_validation_error_for_not_selecting_whether_to_convert_potential_placement_information
    expect(page).to have_validation_error("Please select if you would like to convert your current information")
  end

  def then_i_see_a_validation_error_for_not_selecting_a_primary_placement
    expect(page).to have_validation_error("Primary placements can't be blank")
  end

  def and_i_see_a_validation_error_for_not_selecting_a_secondary_placement
    expect(page).to have_validation_error("Secondary placements can't be blank")
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_current_path(placements_school_placements_path(@school))
  end
  alias_method :and_i_see_the_placements_index_page, :then_i_see_the_placements_index_page

  def and_i_see_1_placements_for_primary_year_2
    expect(page).to have_table_row({
      "Placement" => "Primary (Year 2)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Any time in the academic year",
      "Provider" => "Provider not assigned",
    })
  end

  def and_i_see_2_placements_for_secondary_science
    expect(page).to have_table_row({
      "Placement" => "Science",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Any time in the academic year",
      "Provider" => "Provider not assigned",
    })

    expect(page).to have_element(:td, text: "Science", count: 2)
  end

  def and_i_see_my_hosting_interest_is_may_offer_placements
    expect(page).to have_tag("May offer placements", "yellow")
    expect(page).to have_paragraph(
      "Providers can see your placement preferences and will be able to user your email to contact you.",
    )
    expect(page).to have_paragraph(
      "Once you are sure which placements your school can offer, add your placements. You can then assign your placements to providers.",
    )
  end

  def and_i_see_my_information_was_added_successfully
    expect(page).to have_success_banner(
      "Information added",
      "Your school has available placements. Add further placements if you can offer more.",
    )
  end

  def and_i_see_my_hosting_interest_is_placements_available
    expect(page).to have_tag("Placements available", "green")
    expect(page).to have_paragraph(
      "Add and edit placements to let providers know your preferences.",
    )
    expect(page).to have_paragraph(
      "If you know the providers you want to work with, assign them to your placements. " \
      "This will prevent other providers getting in contact with you about them.",
    )
    expect(page).to have_paragraph(
      "If your circumstances change and you are no longer able to offer placements, change your status.",
    )
  end
end
