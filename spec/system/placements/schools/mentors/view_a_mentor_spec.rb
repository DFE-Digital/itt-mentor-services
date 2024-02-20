require "rails_helper"

RSpec.describe "Placements / Schools / Mentors / View a mentor", type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "School 1") }
  let(:mentor) do
    create(:placements_mentor,
           first_name: "John",
           last_name: "Doe",
           trn: "1234567")
  end

  before do
    school
    given_i_sign_in_as_anne
  end

  scenario "Support User views a school mentor's details" do
    given_a_mentor_exists_in(school:)
    when_i_visit_the_show_page_for(school, mentor)
    then_i_see_the_mentor_details(
      first_name: "John",
      last_name: "Doe",
      trn: "1234567",
    )
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    and_user_has_one_school(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

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
    expect(page).to have_content("#{first_name} #{last_name}")

    within(".govuk-summary-list") do
      expect(page).to have_content(first_name)
      expect(page).to have_content(last_name)
      expect(page).to have_content(trn)
    end
  end

  def and_user_has_one_school(user:)
    create(:user_membership, user:, organisation: school)
  end
end
