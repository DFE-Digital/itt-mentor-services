require "rails_helper"

RSpec.describe "School user publishes without a hosting interest", service: :placements, type: :system do
  scenario "providers can discover a first-time school's publication" do
    given_a_first_time_school
    when_i_publish_a_placement
    then_the_school_has_no_hosting_interest
    when_i_sign_in_as_a_provider
    then_i_can_find_the_school
    when_i_open_the_school
    then_i_can_view_its_placements_and_contact
    when_i_select_all_schools
    then_i_can_find_the_school
    when_i_open_the_school
    then_i_can_view_its_placements_and_contact
  end

  scenario "deleting, replacing and deleting the last placement" do
    given_a_school_with_a_last_placement
    when_i_delete_the_last_placement
    then_the_school_has_no_hosting_interest
    when_i_publish_a_placement
    then_the_school_has_no_hosting_interest
    when_i_delete_the_last_placement
    then_the_school_has_no_hosting_interest
    and_the_school_has_no_placements
  end

  private

  def given_a_first_time_school
    @academic_year = Placements::AcademicYear.current.next
    @school = create(:placements_school, :primary, name: "Springfield Primary", expression_of_interest_completed: false, with_hosting_interest: false)
    create(:subject, :primary, name: "Primary", code: "00")
    sign_in_placements_user(organisations: [@school])
  end

  def given_a_school_with_a_last_placement
    @academic_year = Placements::AcademicYear.current.next
    @school = create(:placements_school, :primary, expression_of_interest_completed: false)
    subject = create(:subject, :primary, name: "Primary", code: "00")
    create(:placement, school: @school, subject:, academic_year: @academic_year, year_group: :year_1)
    sign_in_placements_user(organisations: [@school])
  end

  def when_i_publish_a_placement
    click_on "Add placement", exact: true
    choose "Year 1"
    click_on "Continue"
    choose "Next year (#{@academic_year.name})"
    click_on "Continue"
    click_on "Continue"
    click_on "Publish placement"
    expect(page).to have_success_banner("Placement added")
    expect(@school.placements.count).to eq(1)
  end

  def then_the_school_has_no_hosting_interest
    expect(@school.reload.hosting_interests).to be_empty
    expect(@school.expression_of_interest_completed).to be(false)
  end

  def when_i_sign_in_as_a_provider
    Capybara.reset_sessions!
    @provider = create(:placements_provider)
    sign_in_placements_user(organisations: [@provider])
    visit placements_provider_find_index_path(@provider)
  end

  def then_i_can_find_the_school
    expect(page).to have_h2(@school.name)
    expect(page).to have_tag("Placements available", "green")
  end

  def when_i_open_the_school
    click_on @school.name
  end

  def then_i_can_view_its_placements_and_contact
    expect(page).to have_h1(@school.name)
    expect(page).to have_h2("1 unfilled placement")
    expect(page).to have_link("Primary (Year 1)")
    click_on "Contact"
    expect(page).to have_h2("Placement contact")
    click_on "School details"
    expect(page).to have_h1(@school.name)
    click_on "Placements", exact: true
    expect(page).to have_h2("1 unfilled placement")
  end

  def when_i_select_all_schools
    visit placements_provider_find_index_path(@provider)
    choose "All schools"
    click_on "Apply filters"
  end

  def when_i_delete_the_last_placement
    placement = @school.placements.sole
    visit placements_school_placement_path(@school, placement)
    click_on "Delete placement"
    click_on "Delete placement"
    expect(page).to have_current_path(placements_school_placements_path(@school))
    expect(page).to have_success_banner("Placement deleted")
  end

  def and_the_school_has_no_placements
    expect(@school.placements).to be_empty
  end
end
