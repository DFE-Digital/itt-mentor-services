require "rails_helper"

RSpec.describe "School user does not select a phase",
               service: :placements,
               type: :system do
  scenario do
    given_academic_years_exist
    and_subjects_exist
    and_a_school_exists_with_a_hosting_interest_and_potential_placement_details
    and_i_am_signed_in
    when_i_visit_the_edit_potential_placement_details_page
    then_i_see_the_phase_known_page
    and_primary_is_pre_selected
    and_secondary_is_pre_selected

    when_i_unselect_primary
    and_i_unselect_secondary
    and_i_click_on_continue
    then_i_see_a_validation_error_for_selecting_a_phase
  end

  private

  def given_academic_years_exist
    current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = current_academic_year.name
    @next_academic_year = current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_subjects_exist
    @primary = create(:subject, :primary, name: "Primary")

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
    @school = create(:placements_school, potential_placement_details:)
    @hosting_interest = create(
      :hosting_interest,
      school: @school,
      academic_year: @next_academic_year,
      appetite: "interested",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_visit_the_edit_potential_placement_details_page
    visit new_edit_potential_placements_placements_school_potential_placements_path(@school)
  end

  def then_i_see_the_phase_known_page
    expect(page).to have_title(
      "What education phase could you offer placements in? - Manage school placements - GOV.UK",
    )
    expect(page).to have_element(
      :legend,
      text: "What education phase could you offer placements in?",
      class: "govuk-fieldset__legend",
    )
    expect(page).to have_field("Primary", type: :checkbox)
    expect(page).to have_field("Secondary", type: :checkbox)
    expect(page).to have_field("I don’t know", type: :checkbox)
  end

  def and_primary_is_pre_selected
    expect(page).to have_field("Primary", type: :checkbox, checked: true)
  end

  def and_secondary_is_pre_selected
    expect(page).to have_field("Secondary", type: :checkbox, checked: true)
  end

  def when_i_unselect_primary
    uncheck "Primary"
  end

  def and_i_unselect_secondary
    uncheck "Secondary"
  end

  def when_i_click_on_continue
    click_on "Continue"
  end
  alias_method :and_i_click_on_continue,
               :when_i_click_on_continue

  def then_i_see_a_validation_error_for_selecting_a_phase
    expect(page).to have_validation_error(
      "Please select which phase you are looking to host placements at",
    )
  end
end
