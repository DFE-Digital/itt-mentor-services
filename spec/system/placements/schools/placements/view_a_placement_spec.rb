require "rails_helper"

RSpec.describe "Placements / Schools / Placements / View a placement",
               service: :placements, type: :system do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:) }
  let!(:subject_1) { create(:subject, name: "Subject 1", subject_area: :primary) }
  let!(:provider) { create(:provider, name: "Provider 1") }
  let(:partnership) { create(:placements_partnership, provider:, school:) }

  before do
    given_i_sign_in_as_anne
  end

  context "with subjects" do
    let!(:subject_2) { create(:subject, name: "Subject 2") }
    let!(:subject_3) { create(:subject, name: "Subject 3") }

    scenario "User views a placement with a subject that has no child subjects" do
      given_a_placement_has_one_subject(subject_1)
      when_i_visit_the_placement_show_page
      then_i_see_the_subject_name_in_the_placement_details("Subject 1")
    end

    scenario "User views a placement with child subjects" do
      given_a_placement_with_a_subject_which_has_child_subjects(subject_1, [subject_2, subject_3])
      when_i_visit_the_placement_show_page
      then_i_see_all_of_the_subjects_names_in_the_placement_details(["Subject 2", "Subject 3"])
    end
  end

  context "with mentors" do
    let!(:mentor_1) { create(:placements_mentor, first_name: "Joe", last_name: "Bloggs") }
    let!(:mentor_2) { create(:placements_mentor, first_name: "John", last_name: "Doe") }
    let!(:mentor_3) { create(:placements_mentor, first_name: "Agatha", last_name: "Christie") }

    before do
      given_a_placement_has_one_subject(subject_1)
      given_the_school_has_mentors(school:, mentors: [mentor_1, mentor_2, mentor_3])
    end

    scenario "User views a placement with one mentor" do
      given_a_placement_with_one_mentor(mentor_1)
      when_i_visit_the_placement_show_page
      then_i_see_the_mentor_name_in_the_placement_details("Joe Bloggs")
    end

    scenario "User views a placement with multiple mentors" do
      given_a_placement_with_multiple_mentors([mentor_1, mentor_2, mentor_3])
      when_i_visit_the_placement_show_page
      then_i_see_all_of_the_mentors_names_in_the_placement_details(
        ["Joe Bloggs", "John Doe", "Agatha Christie"],
      )
    end
  end

  context "without a mentor" do
    before do
      given_a_placement_has_one_subject(subject_1)
    end

    context "when the school has no mentors" do
      scenario "User views a placement with no mentors" do
        given_a_placement_with_no_mentor
        when_i_visit_the_placement_show_page
        then_i_see_the_mentor_is_not_yet_known_in_the_placement_details(change_link: "Add a mentor")
      end
    end

    context "when the school has mentors" do
      let!(:mentor_1) { create(:placements_mentor, first_name: "Joe", last_name: "Bloggs") }

      before do
        given_the_school_has_mentors(school:, mentors: [mentor_1])
      end

      scenario "User views a placement with no mentors" do
        given_a_placement_with_no_mentor
        when_i_visit_the_placement_show_page
        then_i_see_the_mentor_is_not_yet_known_in_the_placement_details(change_link: "Select a mentor")
      end
    end
  end

  context "with school level" do
    before do
      given_a_placement_has_one_subject(subject_1)
    end

    scenario "User views a placement in a school with phase All-through" do
      given_a_placement_in_a_school_with_phase("All-through")
      when_i_visit_the_placement_show_page
      then_i_see_the_school_level_in_the_placement_details(school_level: "")
    end
  end

  context "without school level" do
    before do
      given_a_placement_has_one_subject(subject_1)
    end

    scenario "User views a placement in a primary only school" do
      given_a_placement_in_a_school_with_phase("Primary")
      when_i_visit_the_placement_show_page
      then_i_do_not_see_the_school_level_in_the_placement_details(school_level: "Primary")
    end

    scenario "User views a placement in a secondary only school" do
      given_a_placement_in_a_school_with_phase("Secondary")
      when_i_visit_the_placement_show_page
      then_i_do_not_see_the_school_level_in_the_placement_details(school_level: "Secondary")
    end
  end

  context "with a provider" do
    before { partnership }

    scenario "User views a placement with a provider" do
      given_a_placement_with_a_provider(provider:)
      when_i_visit_the_placement_show_page
      then_i_see_the_provider_in_the_placement_details(provider_name: "Provider 1")
    end
  end

  context "without a provider" do
    context "when the school has no partner providers" do
      scenario "User views a placement without a provider" do
        when_i_visit_the_placement_show_page
        then_i_see_link(
          text: "Add a partner provider",
          href: placements_school_partner_providers_path(school),
        )
      end
    end

    context "when the school has partner providers" do
      before { partnership }

      scenario "User views a placement without a provider" do
        when_i_visit_the_placement_show_page
        then_i_see_link(
          text: "Assign a provider",
          href: new_edit_placement_placements_school_placement_path(school, placement, step: :provider),
        )
      end
    end
  end

  context "when I preview the placement" do
    scenario "I can see the placement details" do
      given_i_visit_the_placement_show_page
      and_i_click_link("preview this placement")
      then_i_see_the_placement_preview_page
    end
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
    create(:user_membership, user:, organisation: school)
  end

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_placement_show_page
    visit placements_school_placement_path(school, placement)
  end

  alias_method :given_i_visit_the_placement_show_page, :when_i_visit_the_placement_show_page

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def given_a_placement_has_one_subject(placements_subject)
    placement.update(subject: placements_subject)
  end

  def then_i_see_the_subject_name_in_the_placement_details(subject_name)
    expect(page.find(".govuk-heading-l")).to have_content(subject_name)

    within(".govuk-summary-list") do
      expect(page).to have_content(subject_name)
    end
  end

  def given_a_placement_with_a_subject_which_has_child_subjects(subject, child_subjects)
    placement.update!(subject:)

    child_subjects.each do |child_subject|
      child_subject.update!(parent_subject: subject)
      Placements::PlacementAdditionalSubject.create!(placement:, subject: child_subject)
    end
  end

  def then_i_see_all_of_the_subjects_names_in_the_placement_details(additional_subject_names)
    expect(page.find(".govuk-heading-l")).to have_content(additional_subject_names.sort.to_sentence)
    within(".govuk-summary-list") do
      expect(page).to have_content(additional_subject_names.sort.to_sentence)
    end
  end

  def given_a_placement_with_no_mentor; end

  def given_a_placement_with_one_mentor(mentor)
    PlacementMentorJoin.create!(placement:, mentor:)
  end

  def then_i_see_the_mentor_name_in_the_placement_details(mentor_name)
    within(".govuk-summary-list") do
      expect(page).to have_content(mentor_name)
    end
  end

  def given_the_school_has_mentors(school:, mentors:)
    mentors.each do |mentor|
      create(:placements_mentor_membership, school:, mentor:)
    end
  end

  def given_a_placement_with_multiple_mentors(mentors)
    mentors.each do |mentor|
      PlacementMentorJoin.create!(placement:, mentor:)
    end
  end

  def then_i_see_all_of_the_mentors_names_in_the_placement_details(mentor_names)
    mentor_names.each do |mentor_name|
      then_i_see_the_mentor_name_in_the_placement_details(mentor_name)
    end
    expect(page).to have_content("Change")
  end

  def then_i_see_the_mentor_is_not_yet_known_in_the_placement_details(change_link:)
    within(".govuk-summary-list") do
      expect(page).to have_content(change_link)
    end
  end

  def given_a_placement_in_a_school_with_phase(phase)
    school.update!(phase:)
  end

  def then_i_do_not_see_the_school_level_in_the_placement_details(school_level:)
    within(".govuk-summary-list") do
      expect(page).not_to have_content(school_level)
    end
  end

  def then_i_see_the_school_level_in_the_placement_details(school_level:)
    within(".govuk-summary-list") do
      expect(page).to have_content(school_level)
    end
  end

  def given_a_placement_with_status(status)
    placement.update!(status:)
  end

  def given_a_placement_with_a_provider(provider:)
    placement.update!(provider:)
  end

  def then_i_see_the_provider_in_the_placement_details(
    provider_name:, change_link: "Change"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(provider_name)
      expect(page).to have_content(change_link)
    end
  end

  def then_see_the_status_in_the_placement_details(status:)
    within(".govuk-summary-list") do
      expect(page.find(".govuk-tag")).to have_content(status)
    end
  end

  def then_i_see_link(text:, href:)
    expect(page).to have_link(text, href:)
  end

  def when_i_visit_the_placement_preview_page
    click_link "preview this placement"
  end

  def and_i_click_link(link_text)
    click_link link_text
  end

  def then_i_see_the_placement_preview_page
    expect(page).to have_content("This is a preview of how your placement appears to teacher training providers.")
  end
end
