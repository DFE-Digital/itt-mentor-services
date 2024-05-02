require "rails_helper"

RSpec.describe "Placements / Schools / Placements / Add a placement",
               type: :system, service: :placements do
  let(:school) { build(:placements_school, name: "School 1", phase: "Primary") }
  let!(:subject_1) { create(:subject, name: "Primary subject", subject_area: :primary) }
  let!(:subject_2) { create(:subject, name: "Secondary subject", subject_area: :secondary) }
  let!(:subject_3) { create(:subject, name: "Secondary subject 2", subject_area: :secondary) }
  let!(:mentor_1) { create(:placements_mentor_membership, school:).mentor }
  let!(:mentor_2) { create(:placements_mentor_membership, school:).mentor }

  before do
    given_i_sign_in_as_anne
  end

  context "when I am part of a primary school" do
    scenario "I can create my placement" do
      when_i_visit_the_placements_page
      and_i_click_on("Add placement")
      then_i_see_the_add_a_placement_subject_page(school.phase)
      when_i_choose_a_subject(subject_1.name)
      and_i_click_on("Continue")
      then_i_see_the_add_a_placement_mentor_page
      when_i_check_a_mentor(mentor_1.full_name)
      and_i_click_on("Continue")
      then_i_see_the_check_your_answers_page(school.phase, mentor_1)
      and_i_cannot_change_the_phase
      when_i_click_on("Publish placement")
      then_i_see_the_placements_page
      and_i_see_my_placement(school.phase)
    end

    scenario "when I select not known for the mentor" do
      when_i_visit_the_placements_page
      and_i_click_on("Add placement")
      when_i_choose_a_subject(subject_1.name)
      and_i_click_on("Continue")
      then_i_see_the_add_a_placement_mentor_page
      when_i_check_a_mentor("Not known")
      and_i_click_on("Continue")
      then_i_see_the_check_your_answers_page(school.phase, nil)
      when_i_change_my_mentor
      then_see_that_not_known_is_selected
      when_i_click_on("Continue")
      and_i_click_on("Publish placement")
      then_i_see_the_placements_page
      and_i_see_my_placement(school.phase)
    end

    context "when using page navigation" do
      scenario "I can navigate back to the index page with cancel" do
        when_i_visit_the_add_phase_page
        and_i_click_on("Cancel")
        then_i_see_the_placements_page

        when_i_visit_the_add_subject_page
        and_i_click_on("Cancel")
        then_i_see_the_placements_page

        when_i_visit_the_add_mentor_page
        and_i_click_on("Cancel")
        then_i_see_the_placements_page

        when_i_visit_the_check_your_answers_page
        and_i_click_on("Cancel")
        then_i_see_the_placements_page
      end

      scenario "I can navigate to the previous page using the back button" do
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_subject(subject_1.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Back")
        then_i_see_the_add_a_placement_subject_page(school.phase)
        and_i_click_on("Back")
        then_i_see_the_placements_page
      end

      context "When I've checked my answers and I click on change"
      scenario "I can navigate back to the check my answers page with the back button" do
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_subject(subject_1.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page(school.phase, mentor_1)
        when_i_change_my_subject
        and_i_click_on("Back")
        then_i_see_the_check_your_answers_page(school.phase, mentor_1)
        when_i_change_my_mentor
        and_i_click_on("Back")
        then_i_see_the_check_your_answers_page(school.phase, mentor_1)
      end

      scenario "my selected options are rendered when navigating using the back button" do
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_subject(subject_1.name)
        and_i_click_on("Continue")
        when_i_click_on("Back")
        then_my_chosen_subject_is_selected(subject_1.name)
        when_i_visit_the_add_mentor_page
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_mentor
        then_my_chosen_mentor_is_checked(mentor_1.full_name)
      end

      scenario "when I do not enter valid options" do
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_subject_page(school.phase)
        and_i_see_the_error_message("Select a subject")

        when_i_choose_a_subject(subject_1.name)
        and_i_click_on("Continue")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        and_i_see_the_error_message("Select a mentor or not known")
      end

      context "when I tamper with the form URL", js: true do
        scenario "I see an error message" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_tamper_with_the_form_url
          and_i_click_on("Continue")
          then_i_see_an_error_page
        end
      end
    end
  end

  context "when I am part of a secondary school" do
    scenario "I can create my placement" do
      school.update!(phase: "Secondary")
      when_i_visit_the_placements_page
      and_i_click_on("Add placement")
      then_i_see_the_add_a_placement_subject_page(school.phase)
      when_i_check_the_subject(subject_2.name)
      and_i_click_on("Continue")
      then_i_see_the_add_a_placement_mentor_page
      when_i_check_a_mentor(mentor_1.full_name)
      and_i_click_on("Continue")
      then_i_see_the_check_your_answers_page(school.phase, mentor_1)
      and_i_cannot_change_the_phase
      when_i_click_on("Publish placement")
      then_i_see_the_placements_page
      and_i_see_my_placement(school.phase)
    end
  end

  context "when I am part of school in a different phase e.g. Nursery" do
    context "and I choose the Primary phase" do
      scenario "I can create my placement" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        then_i_see_the_add_a_placement_add_phase_page
        when_i_choose_a_phase("Primary")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_subject_page("Primary")
        when_i_choose_a_subject(subject_1.name)
        then_i_see_the_add_a_placement_subject_page("Primary")
        when_i_choose_a_subject(subject_1.name)
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Primary", mentor_1)
        and_i_can_change_the_phase
        when_i_click_on("Publish placement")
        then_i_see_the_placements_page
        and_i_see_my_placement("Primary")
      end
    end

    context "and I choose the Secondary phase" do
      scenario "I can create my placement" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        then_i_see_the_add_a_placement_add_phase_page
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_subject_page("Secondary")
        when_i_check_the_subject(subject_2.name)
        and_i_check_the_subject(subject_3.name)
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_1)
        and_i_click_on("Publish placement")
        then_i_see_the_placements_page
        and_i_see_my_placement("Secondary")
      end
    end

    context "and I do not choose a phase" do
      scenario "I see an error message" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_add_phase_page
        and_i_see_the_error_message("Select a phase")
      end
    end

    context "and I click on change my phase" do
      scenario "I decide to change my phase" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_phase
        then_i_see_the_add_a_placement_add_phase_page
        when_i_choose_a_phase("Primary")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_subject_page("Primary")
        when_i_choose_a_subject(subject_1.name)
        when_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Primary", mentor_1)
        and_my_selection_has_changed_to("Primary")
      end

      scenario "I do not decide to change my phase" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_phase
        then_i_see_the_add_a_placement_add_phase_page
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_subject_page("Secondary")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_1)
        and_my_selection_has_not_changed_to("Primary")
      end
    end

    context "and I click on change my subject" do
      scenario "I decide to change my subject" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_subject
        then_i_see_the_add_a_placement_subject_page("Secondary")
        when_i_check_the_subject(subject_3.name)
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_1)
        and_my_selection_has_changed_to(subject_3.name)
      end

      scenario "I do not decide to change my subject" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_subject
        then_i_see_the_add_a_placement_subject_page("Secondary")
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_1)
        and_my_selection_has_not_changed_to(subject_3.name)
      end
    end

    context "and I click on change my mentor" do
      scenario "I decide to change my mentor" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_mentor
        then_i_see_the_add_a_placement_mentor_page
        when_i_check_a_mentor(mentor_2.full_name)
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_2)
      end

      scenario "I do not decide to change my mentor" do
        school.update!(phase: "Nursery")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        when_i_choose_a_phase("Secondary")
        and_i_click_on("Continue")
        when_i_check_the_subject(subject_2.name)
        and_i_click_on("Continue")
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        when_i_change_my_mentor
        then_i_see_the_add_a_placement_mentor_page
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page("Secondary", mentor_1)
      end
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
    click_on "Start now"
  end

  def when_i_visit_the_add_phase_page
    visit add_phase_placements_school_placement_build_index_path(school, :add_phase)
  end

  def when_i_visit_the_placements_page
    visit placements_school_placements_path(school)
  end

  def when_i_visit_the_add_subject_page
    visit add_subject_placements_school_placement_build_index_path(school, :add_subject)
  end

  def when_i_visit_the_add_mentor_page
    visit add_mentors_placements_school_placement_build_index_path(school, :add_mentor)
  end

  def when_i_visit_the_check_your_answers_page
    when_i_visit_the_placements_page
    and_i_click_on("Add placement")
    when_i_choose_a_subject("Primary subject")
    and_i_click_on("Continue")
    when_i_check_a_mentor(mentor_1.full_name)
    and_i_click_on("Continue")
  end

  def given_i_sign_in_as_anne
    and_there_is_an_existing_user_for("Anne")
    and_i_visit_the_sign_in_path
    and_i_click_sign_in
  end

  def then_i_see_the_add_a_placement_add_phase_page
    expect(page).to have_content("Add placement")
    expect(page).to have_content("Phase")
    expect(page).to have_content("Primary")
    expect(page).to have_content("Secondary")
  end

  def then_i_see_the_add_a_placement_subject_page(phase)
    opposite_phase = phase == "Primary" ? "Secondary" : "Primary"
    expect(page).to have_content("Add placement")
    expect(page).to have_content("Subject")
    expect(page).to have_content("#{phase} subject")
    expect(page).not_to have_content("#{opposite_phase} subject")
  end

  def then_i_see_the_placements_page
    expect(page).to have_content("Placements")
    expect(page).to have_content("Add placement")
  end

  def when_i_choose_a_phase(phase)
    page.choose phase
  end

  def when_i_choose_a_subject(subject_name)
    page.choose subject_name
  end

  def when_i_check_the_subject(subject_name)
    page.check subject_name
  end

  def then_i_see_the_add_a_placement_mentor_page
    expect(page).to have_content("Add placement")
    expect(page).to have_content("Mentor")
    expect(page).to have_content(mentor_1.full_name)
    expect(page).to have_content(mentor_2.full_name)
  end

  def and_my_chosen_subject_is_selected(subject_name)
    expect(page).to have_checked_field(subject_name)
  end

  def when_i_check_a_mentor(mentor_name)
    check mentor_name
  end

  def then_i_see_the_check_your_answers_page(phase, mentor)
    expect(page).to have_content("Check your answers")
    expect(page).to have_content(phase)
    expect(page).to have_content("#{phase} subject")
    expect(page).to have_content(mentor.full_name) if mentor.present?
  end

  def and_my_chosen_mentor_is_checked(mentor_name)
    expect(page).to have_checked_field(mentor_name)
  end

  def and_i_see_my_placement(phase)
    expect(page).to have_content("#{phase} subject")
  end

  def and_i_see_the_error_message(message)
    expect(page).to have_content(message)
  end

  def then_i_tamper_with_the_form_url
    page.execute_script("document.querySelector('form').action = '/schools/#{school.id}/placements/new_placement/build/invalid_id'")
  end

  def then_see_that_not_known_is_selected
    expect(page).to have_checked_field("Not known yet")
  end

  def and_i_cannot_change_the_phase
    expect(page).not_to have_link("Change", href: add_phase_placements_school_placement_build_index_path(school, :add_phase, enable_quick_navigation: true))
  end

  def and_i_can_change_the_phase
    expect(page).to have_link("Change", href: add_phase_placements_school_placement_build_index_path(school, :add_phase, enable_quick_navigation: true))
  end

  def when_i_change_my_phase
    click_link "Change", href: add_phase_placements_school_placement_build_index_path(school, :add_phase, enable_quick_navigation: true)
  end

  def when_i_change_my_subject
    click_link "Change", href: add_subject_placements_school_placement_build_index_path(school, :add_subject, enable_quick_navigation: true)
  end

  def when_i_change_my_mentor
    click_link "Change", href: add_mentors_placements_school_placement_build_index_path(school, :add_mentors, enable_quick_navigation: true)
  end

  def then_i_see_an_error_page
    expect(page).to have_content("Sorry, there’s a problem with the service")
  end

  def and_my_selection_has_changed_to(selection)
    expect(page).to have_content(selection)
  end

  def and_my_selection_has_not_changed_to(selection)
    expect(page).not_to have_content(selection)
  end

  def when_i_click_on(text)
    click_on text
  end

  alias_method :and_i_click_on, :when_i_click_on
  alias_method :and_i_check_the_subject, :when_i_check_the_subject
  alias_method :then_my_chosen_subject_is_selected, :and_my_chosen_subject_is_selected
  alias_method :then_my_chosen_mentor_is_checked, :and_my_chosen_mentor_is_checked
end
