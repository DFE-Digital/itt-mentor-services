require "rails_helper"

RSpec.describe "School user edits their hosting interest while having assigned placements",
               service: :placements,
               type: :system do
  scenario do
    given_subjects_exist
    and_academic_years_exist
    and_a_school_exists_with_a_hosting_interest
    and_placements_assigned_to_providers_exist
    and_i_am_signed_in

    when_i_navigate_to_organisation_details
    then_i_see_the_organisation_details_page
    and_i_see_the_hosting_interest_for_the_next_academic_year

    when_i_click_on_change_hosting_status
    then_i_see_i_am_unable_to_change_the_hosting_interest
    and_i_see_the_assigned_placements_listed
  end

  private

  def given_subjects_exist
    @primary = create(:subject, :primary, name: "Primary", code: "00")
  end

  def and_academic_years_exist
    @current_academic_year = Placements::AcademicYear.current
    @current_academic_year_name = @current_academic_year.name
    @next_academic_year = @current_academic_year.next
    @next_academic_year_name = @next_academic_year.name
  end

  def and_a_school_exists_with_a_hosting_interest
    @school = create(:placements_school, with_hosting_interest: false)
    @hosting_interest = create(
      :hosting_interest,
      school: @school,
      academic_year: @next_academic_year,
    )
  end

  def and_placements_assigned_to_providers_exist
    @london_provider = create(:placements_provider, name: "The London Provider")
    @london_provider_placement = create(
      :placement,
      school: @school,
      academic_year: @next_academic_year,
      provider: @london_provider,
      subject: @primary,
      year_group: :year_1,
    )

    @brixton_provider = create(:placements_provider, name: "The Brixton Provider")
    @brixton_provider_placement = create(
      :placement,
      school: @school,
      academic_year: @next_academic_year,
      provider: @brixton_provider,
      subject: @primary,
      year_group: :year_5,
    )

    @current_academic_year_placement = create(
      :placement,
      school: @school,
      academic_year: @current_academic_year,
      provider: @brixton_provider,
      subject: @primary,
      year_group: :year_3,
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_navigate_to_organisation_details
    within(primary_navigation) do
      click_on "Organisation details"
    end
  end

  def then_i_see_the_organisation_details_page
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_title(
      "Organisation details - Manage school placements - GOV.UK",
    )
    expect(page).to have_h1(@school.name)
    expect(page).to have_h2("Hosting status")
    expect(page).to have_element(
      :p,
      text: "This status indicates to providers whether you intend to host placements.",
      class: "govuk-body",
    )
  end

  def and_i_see_the_hosting_interest_for_the_next_academic_year
    expect(page).to have_summary_list_row(
      "Status", "Open to hosting"
    )
  end

  def when_i_click_on_change_hosting_status
    click_on "Change Hosting status"
  end

  def then_i_see_i_am_unable_to_change_the_hosting_interest
    expect(page).to have_current_item("Organisation details")
    expect(page).to have_title(
      "You cannot change your placement availability because you have providers assigned to your placements - Placement details - Manage school placements - GOV.UK",
    )
    expect(page).to have_span_caption("Placement details")
    expect(page).to have_h1("You cannot change your placement availability because you have providers assigned to your placements")
    expect(page).to have_paragraph(
      "You must remove any providers from your placements before they can be removed.",
    )
    expect(page).to have_paragraph(
      "It is your responsibility to speak to providers to ensure they do not place trainees at your school.",
    )
    expect(page).to have_link("Cancel", href: placements_school_path(@school))
  end

  def and_i_see_the_assigned_placements_listed
    expect(page).to have_h2("Your placements")
    expect(page).to have_table_row({
      "Placement" => "Primary (Year 1)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Any time in the academic year",
      "Provider" => "The London Provider",
    })

    expect(page).to have_table_row({
      "Placement" => "Primary (Year 5)",
      "Mentor" => "Mentor not assigned",
      "Expected date" => "Any time in the academic year",
      "Provider" => "The Brixton Provider",
    })

    expect(page).not_to have_table_row({
      "Placement" => "Primary (Year 3)",
    })
  end
end
