require "rails_helper"

RSpec.describe "Placements / Support / Schools / Placement / Support User views a placement",
               service: :placements, type: :system do
  let(:school) { create(:placements_school, name: "School 1", phase:) }
  let(:mentor) { create(:placements_mentor) }
  let(:phase) { "All-through" }
  let(:year_group) { :year_1 }
  let!(:primary_subject) { create(:subject, name: "Primary with science", subject_area: :primary) }
  let!(:secondary_subject) { create(:subject, name: "Maths", subject_area: :secondary) }

  before do
    school
    given_i_sign_in_as_colin
  end

  describe "school phases" do
    context "when the school phase is All-through" do
      let(:placement) do
        create(:placement, school:, subject: primary_subject, year_group:)
      end

      scenario "Support User views a school placement's details, with school level displayed" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Primary",
          year_group: "Year 1",
          subject: "Primary with science",
          mentors: ["Add a mentor"],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Change")
      end
    end

    context "when the school phase is Primary" do
      let(:phase) { "Primary" }
      let(:placement) do
        create(:placement, school:, subject: primary_subject, year_group:)
      end

      scenario "Support User views a school placement's details, with no school level displayed" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          year_group: "Year 1",
          subject: "Primary with science",
          mentors: ["Add a mentor"],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Change")
      end
    end

    context "when the school phase is Secondary" do
      let(:phase) { "Secondary" }
      let(:placement) do
        create(:placement, school:, subject: secondary_subject)
      end

      scenario "Support User views a school placement's details, with no school level displayed" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          subject: "Maths",
          mentors: ["Add a mentor"],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Add a mentor")
      end
    end
  end

  describe "mentors" do
    context "when there are no mentors assigned to a placement" do
      let(:placement) do
        create(:placement, school:, subject: primary_subject, year_group:)
      end

      scenario "Support User views a school placement's details" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Primary",
          year_group: "Year 1",
          subject: "Primary with science",
          mentors: ["Add a mentor"],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Change")
      end
    end

    context "when there there is one mentor assigned to a placement" do
      let(:placement) do
        create(:placement, school:, mentors: [mentor], subject: primary_subject, year_group:)
      end

      scenario "Support User views a school placement's details, with mentor name displayed" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Primary",
          year_group: "Year 1",
          subject: "Primary with science",
          mentors: [mentor.full_name],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Change")
      end
    end

    context "when there are multiple mentors assigned to a placement" do
      let(:placement) do
        create(:placement, school:, mentors: [mentor, create(:placements_mentor)],
                           subject: primary_subject, year_group:)
      end

      scenario "Support User views a school placement's details, with all mentor names displayed" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Primary",
          year_group: "Year 1",
          subject: "Primary with science",
          mentors: placement.mentors.map(&:full_name),
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Change")
      end
    end
  end

  describe "provider" do
    context "when there is no provider assigned to a placement" do
      let(:placement) do
        create(:placement, school:, subject: secondary_subject)
      end

      scenario "Support User views a school placement's details" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Secondary",
          subject: "Maths",
          mentors: ["Add a mentor"],
          provider: "Add a partner provider",
        )
        and_i_should_see_link("Add a mentor")
      end
    end

    context "when there is a provider assigned to a placement, with provider name displayed" do
      let(:provider) { create(:placements_provider) }
      let(:placement) do
        create(:placement, school:, subject: secondary_subject, provider:)
      end

      scenario "Support User views a school placement's details" do
        when_i_visit_the_support_show_page_for(school, placement)
        then_i_see_the_placement_details(
          school_name: "School 1",
          school_level: "Secondary",
          subject: "Maths",
          mentors: ["Add a mentor"],
          provider: provider.name,
          status: "Unavailable",
        )
        and_i_should_see_link("Change")
      end
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

  def then_i_see_the_placement_details(school_name:, subject:, mentors:,
                                       provider:, school_level: nil,
                                       year_group: nil,
                                       status: "Available")
    expect(page).to have_content(school_name)
    expect(page).to have_content(subject)
    expect(page).to have_content(status)

    within(".govuk-summary-list") do
      if school.phase == "All-through"
        expect(page).to have_content("School level")
        expect(page).to have_content(school_level)
      else
        expect(page).not_to have_content("School level")
      end
      if placement.year_group.present?
        expect(page).to have_content("Year group")
        expect(page).to have_content(year_group)
      else
        expect(page).not_to have_content("Year group")
      end
      expect(page).to have_content(subject)
      mentors.each do |mentor|
        expect(page).to have_content(mentor)
      end
      expect(page).to have_content(provider)
    end
  end

  def and_i_should_see_link(link_text)
    expect(page).to have_link(link_text)
  end
end
