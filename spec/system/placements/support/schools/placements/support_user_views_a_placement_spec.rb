require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placement / Support User views a placement",
               type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "School 1", phase: "Nursery") }
  let(:placement) do
    create(:placement, school:, mentors: [mentor], subjects: [subject], status: "published", start_date: nil,
                       end_date: nil)
  end
  let(:mentor) { create(:placements_mentor) }
  let(:subject) { create(:subject, name: "Maths", subject_area: :primary) }

  before do
    school
    given_i_sign_in_as_colin
  end

  scenario "Support User views a school placement's details" do
    when_i_visit_the_support_show_page_for(school, placement)
    then_i_see_the_placement_details(
      school_name: "School 1",
      school_level: "Primary",
      subjects: "Maths",
      mentors: placement.mentors.map(&:full_name).to_sentence,
      window: "Not known",
      status: "Published",
    )
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def when_i_visit_the_support_show_page_for(school, placement)
    visit placements_support_school_placement_path(school, placement)
  end

  def then_i_see_the_placement_details(school_name:, school_level:, subjects:, mentors:, window:, status:)
    expect(page).to have_content(school_name)
    expect(page).to have_content(subjects)

    within(".govuk-summary-list") do
      expect(page).to have_content(school_level)
      expect(page).to have_content(subjects)
      expect(page).to have_content(mentors)
      expect(page).to have_content(window)
      expect(page).to have_content(status)
    end
  end
end
