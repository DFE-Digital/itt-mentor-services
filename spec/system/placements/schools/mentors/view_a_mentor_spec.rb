require "rails_helper"

RSpec.describe "Placements / Schools / Mentors / View a mentor", service: :placements, type: :system do
  let(:school) { create(:placements_school, name: "School 1") }
  let(:mentor) do
    create(:placements_mentor,
           first_name: "John",
           last_name: "Doe",
           trn: "1234567")
  end

  before do
    given_i_am_signed_in_as_a_placements_user(organisations: [school])
  end

  scenario "User views a school mentor's details" do
    given_a_mentor_exists_in(school:)
    when_i_visit_the_show_page_for(school, mentor)
    then_i_see_the_mentor_details(
      first_name: "John",
      last_name: "Doe",
      trn: "1234567",
    )
  end

  private

  def given_a_mentor_exists_in(school:)
    create(:placements_mentor_membership, school:, mentor:)
  end

  def when_i_visit_the_show_page_for(school, mentor)
    visit placements_school_mentor_path(
      school_id: school.id,
      id: mentor.id,
    )
  end

  def then_i_see_the_mentor_details(first_name:, last_name:, trn:)
    expect(page).to have_h1("#{first_name} #{last_name}")
    expect(page).to have_summary_list_row("First name", first_name)
    expect(page).to have_summary_list_row("Last name", last_name)
    expect(page).to have_summary_list_row("Teacher reference number (TRN)", trn)
  end
end
