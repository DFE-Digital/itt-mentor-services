require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placement / Support User views a placement",
               type: :system, service: :placements do
  let(:school) { create(:placements_school, name: "School 1", phase: "All-through") }
  let(:placement) do
    create(:placement, school:, subject:)
  end
  let(:mentor) { create(:placements_mentor) }
  let!(:subject) { create(:subject, name: "Maths", subject_area: :primary) }

  before do
    school
    given_i_sign_in_as_colin
  end

  context "when there are no mentors assigned to a placement", js: true do
    scenario "Support User views a school placement's details" do
      when_i_visit_the_support_show_page_for(school, placement)
      then_i_see_the_placement_details(
        school_name: "School 1",
        school_level: "Primary",
        subject: "Maths",
        mentors: ["Not yet known"],
      )
    end
  end

  context "when there there is one mentor assigned to a placement" do
    let(:placement) do
      create(:placement, school:, mentors: [mentor], subject:)
    end

    scenario "Support User views a school placement's details" do
      when_i_visit_the_support_show_page_for(school, placement)
      then_i_see_the_placement_details(
        school_name: "School 1",
        school_level: "Primary",
        subject: "Maths",
        mentors: placement.mentors.map(&:full_name),
      )
    end
  end

  context "when there are multiple mentors assigned to a placement" do
    let(:placement) do
      create(:placement, school:, mentors: [mentor, create(:placements_mentor)], subject: subject)
    end

    scenario "Support User views a school placement's details" do
      when_i_visit_the_support_show_page_for(school, placement)
      then_i_see_the_placement_details(
        school_name: "School 1",
        school_level: "Primary",
        subject: "Maths",
        mentors: placement.mentors.map(&:full_name),
      )
    end
  end

  context "when there is one subject assigned to a placement" do
    scenario "Support User views a school placement's details" do
      when_i_visit_the_support_show_page_for(school, placement)
      then_i_see_the_placement_details(
        school_name: "School 1",
        school_level: "Primary",
        subject: "Maths",
        mentors: placement.mentors.map(&:full_name),
      )
    end
  end

  context "when there are multiple subject assigned to a placement" do
    let(:placement) do
      create(:placement, school:, mentors: [mentor], subject:)
    end

    scenario "Support User views a school placement's details" do
      when_i_visit_the_support_show_page_for(school, placement)
      then_i_see_the_placement_details(
        school_name: "School 1",
        school_level: "Primary",
        subject: "Maths",
        mentors: placement.mentors.map(&:full_name),
      )
    end
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

  def then_i_see_the_placement_details(school_name:, school_level:, subject:, mentors:)
    expect(page).to have_content(school_name)
    expect(page).to have_content(subject)

    within(".govuk-summary-list") do
      expect(page).to have_content(school_level)
      expect(page).to have_content(subject)
      mentors.each do |mentor|
        expect(page).to have_content(mentor)
      end
    end
  end
end
