require "rails_helper"

RSpec.describe "School user changes their selected academic year",
               service: :placements,
               type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in
    and_i_see_the_organisations_page

    when_i_click_on_springfield_elementary
    then_i_see_the_placements_index_page
    and_i_see_the_placements_for_the_next_academic_year
    and_i_do_not_see_placements_for_this_academic_year

    when_i_click_on_change_academic_year
    then_i_see_the_academic_year_selection_page

    when_i_select_this_year
    and_i_click_on_save_and_continue
    then_i_see_a_success_message
    and_i_see_the_organisations_page

    when_i_click_on_springfield_elementary
    and_i_am_on_the_placements_index_page
    and_i_see_the_placements_for_this_academic_year
    and_i_do_not_see_placements_for_the_next_academic_year
  end

  private

  def given_that_placements_exist
    @springfield_school = create(
      :placements_school,
      name: "Springfield Elementary",
    )

    @hogwarts_school = create(
      :placements_school,
      name: "Hogwarts",
    )

    @current_academic_year = Placements::AcademicYear.current
    @next_academic_year = @current_academic_year.next

    @current_academic_year_placements = create(
      :placement,
      school: @springfield_school,
      subject: create(:subject, name: "English"),
      academic_year: @current_academic_year,
    )

    @next_academic_year_placements = create(
      :placement,
      school: @springfield_school,
      subject: create(:subject, name: "Science"),
      academic_year: @next_academic_year,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@springfield_school, @hogwarts_school])
  end

  def and_i_see_the_organisations_page
    expect(page).to have_h1("Organisations")
    expect(page).to have_link("Springfield Elementary")
    expect(page).to have_link("Hogwarts")
  end

  def when_i_click_on_springfield_elementary
    click_on "Springfield Elementary"
  end

  def then_i_see_the_placements_index_page
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
  end
  alias_method :and_i_am_on_the_placements_index_page,
               :then_i_see_the_placements_index_page

  def and_i_see_the_placements_for_the_next_academic_year
    expect(page).to have_table_row(
      "Subject" => "Science",
    )
  end

  def and_i_do_not_see_placements_for_this_academic_year
    expect(page).not_to have_table_row(
      "Subject" => "English",
    )
  end

  def when_i_click_on_change_academic_year
    click_on "Change academic year"
  end

  def then_i_see_the_academic_year_selection_page
    expect(page).to have_title("Academic years - Manage school placements - GOV.UK")
    expect(page).to have_element(
      :h1,
      text: "Academic years",
      class: "govuk-fieldset__heading",
    )
    expect(page).to have_element(
      :div,
      text: "Select the academic year for the placements you want to manage.",
      class: "govuk-hint",
    )

    expect(page).to have_field("This year (#{@current_academic_year.name})", type: :radio)
    expect(page).to have_field("Next year (#{@next_academic_year.name})", type: :radio)
  end

  def when_i_select_this_year
    choose "This year (#{@current_academic_year.name})"
  end

  def and_i_click_on_save_and_continue
    click_on "Save and continue"
  end

  def then_i_see_a_success_message
    expect(page).to have_success_banner(
      "Acadmic year changed",
      "You are now viewing placement information for the academic year #{@current_academic_year.name}.",
    )
  end

  def and_i_see_the_placements_for_this_academic_year
    expect(page).to have_table_row(
      "Subject" => "English",
    )
  end

  def and_i_do_not_see_placements_for_the_next_academic_year
    expect(page).not_to have_table_row(
      "Subject" => "Science",
    )
  end
end
