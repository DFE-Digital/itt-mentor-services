require "rails_helper"

RSpec.describe "View a school's latest grant conditions acceptance", service: :claims, type: :system do
  scenario "Support user views a school that has accepted the grant conditions in multiple academic years" do
    given_a_school_has_accepted_the_grant_conditions_in_two_academic_years
    and_i_am_signed_in_as_a_support_user
    when_i_view_the_school_organisation_details
    then_i_see_the_latest_grant_conditions_acceptance
    and_i_do_not_see_the_previous_grant_conditions_acceptance
  end

  scenario "Support user views a school that has only accepted the grant conditions for a previous academic year" do
    given_a_school_has_only_accepted_the_grant_conditions_last_academic_year
    and_i_am_signed_in_as_a_support_user
    when_i_view_the_school_organisation_details
    then_i_see_the_previous_grant_conditions_acceptance
    and_i_do_not_see_the_option_to_remove_the_agreement
  end

  private

  def grant_conditions_year
    AcademicYear.for_latest_claim_window
  end

  def given_a_school_has_accepted_the_grant_conditions_in_two_academic_years
    given_a_school_has_only_accepted_the_grant_conditions_last_academic_year
    create(
      :grant_conditions_acceptance,
      school: @school,
      academic_year: grant_conditions_year,
      accepted_by: create(:claims_user, first_name: "Anne", last_name: "Wilson"),
      accepted_at: Time.zone.parse("1 October #{grant_conditions_year.starts_on.year}"),
    )
  end

  def given_a_school_has_only_accepted_the_grant_conditions_last_academic_year
    @school = create(:claims_school, name: "Hilltop Primary School", grant_conditions_accepted: false)
    create(
      :grant_conditions_acceptance,
      school: @school,
      academic_year: grant_conditions_year.previous,
      accepted_by: create(:claims_user, first_name: "George", last_name: "Barlow"),
      accepted_at: Time.zone.parse("1 October #{grant_conditions_year.previous.starts_on.year}"),
    )
  end

  def and_i_am_signed_in_as_a_support_user
    given_i_sign_in_as(create(:claims_support_user, :colin))
  end

  def when_i_view_the_school_organisation_details
    click_on "Hilltop Primary School"
    click_on "Organisation details"
  end

  def then_i_see_the_latest_grant_conditions_acceptance
    expect(page).to have_summary_list_row("Agreed for", "#{grant_conditions_year.name} academic year")
    expect(page).to have_summary_list_row("Agreed by", "Anne Wilson")
    expect(page).to have_summary_list_row("Agreed on", "1 October #{grant_conditions_year.starts_on.year}")
    expect(page).to have_link("Remove user's agreement to the grant conditions")
  end

  def and_i_do_not_see_the_previous_grant_conditions_acceptance
    expect(page).not_to have_content("George Barlow")
  end

  def then_i_see_the_previous_grant_conditions_acceptance
    expect(page).to have_summary_list_row("Agreed for", "#{grant_conditions_year.previous.name} academic year")
    expect(page).to have_summary_list_row("Agreed by", "George Barlow")
    expect(page).to have_summary_list_row("Agreed on", "1 October #{grant_conditions_year.previous.starts_on.year}")
  end

  def and_i_do_not_see_the_option_to_remove_the_agreement
    expect(page).not_to have_link("Remove user's agreement to the grant conditions")
  end
end
