RSpec.shared_examples "an add a placement wizard" do
  let!(:subject_1) { create(:subject, name: "Primary subject", subject_area: :primary) }
  let!(:subject_2) { create(:subject, name: "Secondary subject", subject_area: :secondary) }
  let!(:subject_3) { create(:subject, name: "Secondary subject 2", subject_area: :secondary) }
  let!(:mentor_1) { create(:placements_mentor) }
  let!(:mentor_2) { create(:placements_mentor) }

  context "when the school has a school contact" do
    let(:school) { build(:placements_school, name: "School 1", phase: "Primary") }

    context "when I am part of a primary school" do
      context "when I have mentors" do
        before do
          create(:placements_mentor_membership, mentor: mentor_1, school:)
          create(:placements_mentor_membership, mentor: mentor_2, school:)
        end

        it "I can create my placement" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page(school.phase, mentor_1)
          and_i_cannot_change_the_phase
          when_i_click_on("Publish placement")
          then_i_see_the_placements_page
          and_i_see_my_placement(school.phase)
          and_i_see_success_message("Placement published")
        end

        it "when I select not known for the mentor" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor("Not yet known")
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page(school.phase, nil)
          when_i_change_my_mentor
          then_see_that_not_known_is_selected
          when_i_click_on("Continue")
          and_i_click_on("Publish placement")
          then_i_see_the_placements_page
          and_i_see_my_placement(school.phase)
          and_i_see_success_message("Placement published")
        end

        it "I am redirected to the add mentor page if I click on the link in the help text" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_expand_the_summary_text
          and_i_click_on("add a mentor")
          then_i_see_the_new_mentor_page
        end
      end

      context "when I have no mentors" do
        it "I do not see the add mentors page" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page(school.phase, nil)
        end
      end

      context "when using page navigation" do
        before do
          create(:placements_mentor_membership, mentor: mentor_1, school:)
          create(:placements_mentor_membership, mentor: mentor_2, school:)
        end

        it "I can navigate back to the index page with cancel" do
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page(school.phase, mentor_1)

          check_your_answers_page = page.current_path

          # 'Cancel' link on the 'Check your answers' page
          when_i_click_on "Cancel"
          then_i_see_the_placements_page

          # 'Cancel' link on the 'Subject' page
          given_i_visit check_your_answers_page
          when_i_click_on "Change Subject"
          and_i_click_on "Cancel"
          then_i_see_the_placements_page

          # 'Cancel' link on the 'Year group' page
          given_i_visit check_your_answers_page
          when_i_click_on "Change Year group"
          and_i_click_on "Cancel"
          then_i_see_the_placements_page

          # 'Cancel' link on the 'Mentor' page
          given_i_visit check_your_answers_page
          when_i_click_on "Change Mentor"
          and_i_click_on "Cancel"
          then_i_see_the_placements_page
        end

        context "when navigating back through the steps" do
          it "my selected options are rendered and I go to the previous step" do
            when_i_visit_the_placements_page
            and_i_click_on("Add placement")
            when_i_choose_a_subject(subject_1.name)
            and_i_click_on("Continue")
            when_i_choose_a_year_group("Year 1")
            and_i_click_on("Continue")
            when_i_check_a_mentor(mentor_1.full_name)
            and_i_click_on("Continue")
            then_i_see_the_check_your_answers_page(school.phase, mentor_1)

            when_i_click_on("Back")
            then_my_chosen_mentor_is_checked(mentor_1.full_name)

            when_i_click_on("Back")
            then_my_chosen_year_group_is_selected("Year 1")

            when_i_click_on("Back")
            then_my_chosen_subject_is_selected(subject_1.name)

            when_i_click_on("Back")
            then_i_see_the_placements_page
          end
        end

        context "when I've checked my answers and I click on change" do
          it "when I do not enter valid options" do
            when_i_visit_the_placements_page
            and_i_click_on("Add placement")
            and_i_click_on("Continue")
            then_i_see_the_add_a_placement_subject_page(school.phase)
            and_i_see_the_error_message("Select a subject")

            when_i_choose_a_subject(subject_1.name)
            and_i_click_on("Continue")
            then_i_see_the_add_year_group_page("Year 1")
            and_i_click_on("Continue")
            and_i_see_the_error_message("Select a year group")
            when_i_choose_a_year_group("Year 1")
            and_i_click_on("Continue")
            then_i_see_the_add_a_placement_mentor_page
            when_i_click_on("Continue")
            and_i_see_the_error_message("Select a mentor or not yet known")
          end
        end
      end
    end

    context "when I am part of a secondary school" do
      before do
        create(:placements_mentor_membership, mentor: mentor_1, school:)
        create(:placements_mentor_membership, mentor: mentor_2, school:)
      end

      it "I can create my placement" do
        school.update!(phase: "Secondary")
        when_i_visit_the_placements_page
        and_i_click_on("Add placement")
        then_i_see_the_add_a_placement_subject_page(school.phase)
        when_i_choose_a_subject(subject_2.name)
        and_i_click_on("Continue")
        then_i_see_the_add_a_placement_mentor_page
        when_i_check_a_mentor(mentor_1.full_name)
        and_i_click_on("Continue")
        then_i_see_the_check_your_answers_page(school.phase, mentor_1)
        and_i_cannot_change_the_phase
        when_i_click_on("Publish placement")
        then_i_see_the_placements_page
        and_i_see_my_placement(school.phase)
        and_i_see_success_message("Placement published")
      end

      context "when I select a subject with child subjects" do
        let!(:subject_3) { create(:subject, name: "Secondary subject 3", subject_area: :secondary, parent_subject: subject_2) }
        let!(:subject_4) { create(:subject, name: "Secondary subject 4", subject_area: :secondary) }

        it "I can create my placement" do
          school.update!(phase: "Secondary")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_2.name)
          and_i_click_on("Continue")
          and_i_check_the_subject(subject_3.name)
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page(school.phase, mentor_1)
          and_i_cannot_change_the_phase
          when_i_click_on("Publish placement")
          then_i_see_the_placements_page
          and_i_see_my_placement(school.phase)
          and_i_see_success_message("Placement published")
        end

        it "I see a validation message if I do not select an additional subject" do
          school.update!(phase: "Secondary")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_2.name)
          and_i_click_on("Continue")
          and_i_click_on("Continue")
          then_i_see_the_add_additional_subjects_page(subject_2)
          and_i_see_the_error_message("Select an additional subject")
        end

        it "If I change the subject, I do not see the additional subject page" do
          school.update!(phase: "Secondary")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_2.name)
          and_i_click_on("Continue")
          then_i_see_the_add_additional_subjects_page(subject_2)
          and_i_click_on("Back")
          then_i_see_the_add_a_placement_subject_page(school.phase)
          when_i_choose_a_subject(subject_4.name)
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
        end
      end
    end

    context "when I am part of school in a different phase e.g. Nursery" do
      before do
        create(:placements_mentor_membership, mentor: mentor_1, school:)
        create(:placements_mentor_membership, mentor: mentor_2, school:)
      end

      context "and I choose the Primary phase" do
        it "I can create my placement" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_add_phase_page
          when_i_choose_a_phase("Primary")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_subject_page("Primary")
          when_i_choose_a_subject(subject_1.name)
          and_i_click_on("Continue")
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page("Primary", mentor_1)
          and_i_can_change_the_phase
          when_i_click_on("Publish placement")
          then_i_see_the_placements_page
          and_i_see_my_placement("Primary")
          and_i_see_success_message("Placement published")
        end
      end

      context "and I choose the Secondary phase" do
        it "I can create my placement" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          then_i_see_the_add_a_placement_add_phase_page
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_subject_page("Secondary")
          when_i_choose_a_subject(subject_2.name)
          and_i_choose_the_subject(subject_3.name)
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page("Secondary", mentor_1)
          and_i_click_on("Publish placement")
          then_i_see_the_placements_page
          and_i_see_my_placement("Secondary")
          and_i_see_success_message("Placement published")
        end
      end

      context "and I do not choose a phase" do
        it "I see an error message" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_add_phase_page
          and_i_see_the_error_message("Select a phase")
        end
      end

      context "and I click on change my phase" do
        it "I decide to change my phase" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
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
          then_i_see_the_add_year_group_page("Year 1")
          when_i_choose_a_year_group("Year 1")
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page("Primary", mentor_1)
          and_my_selection_has_changed_to("Primary")
        end

        it "I do not decide to change my phase" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
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
        it "I decide to change my subject" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
          and_i_click_on("Continue")
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          when_i_change_my_subject
          then_i_see_the_add_a_placement_subject_page("Secondary")
          when_i_choose_a_subject(subject_3.name)
          and_i_click_on("Continue")
          then_i_see_the_add_a_placement_mentor_page
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page("Secondary", mentor_1)
          and_my_selection_has_changed_to(subject_3.name)
        end

        it "I do not decide to change my subject" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
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
        it "I decide to change my mentor" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
          and_i_click_on("Continue")
          when_i_check_a_mentor(mentor_1.full_name)
          and_i_click_on("Continue")
          when_i_change_my_mentor
          then_i_see_the_add_a_placement_mentor_page
          when_i_check_a_mentor(mentor_2.full_name)
          and_i_click_on("Continue")
          then_i_see_the_check_your_answers_page("Secondary", mentor_2)
        end

        it "I do not decide to change my mentor" do
          school.update!(phase: "Nursery")
          when_i_visit_the_placements_page
          and_i_click_on("Add placement")
          when_i_choose_a_phase("Secondary")
          and_i_click_on("Continue")
          when_i_choose_a_subject(subject_2.name)
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
  end

  private

  def given_i_visit(path)
    visit path
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

  def then_i_see_the_add_additional_subjects_page(subject)
    expect(page).to have_content("Add placement")
    expect(page).to have_content(subject.name)

    subject.child_subjects.each do |child_subject|
      expect(page).to have_content(child_subject.name)
    end
  end

  def then_i_see_the_placements_page
    expect(page).to have_content("Placements")
    expect(page).to have_content("Add placement")
  end

  def then_i_see_the_new_mentor_page
    expect(page).to have_content("Add mentor")
    expect(page).to have_content("Find teacher")
  end

  def when_i_expand_the_summary_text
    find(".govuk-details__summary-text").click
  end

  def then_i_see_the_add_year_group_page(year_group)
    expect(page).to have_content("Add placement")
    expect(page).to have_content("Year group")
    expect(page).to have_content(year_group)
  end

  def when_i_choose_a_phase(phase)
    page.choose phase
  end

  def when_i_choose_a_subject(subject_name)
    page.choose subject_name
  end

  def when_i_choose_a_year_group(year_group)
    page.choose year_group
  end

  def when_i_check_a_subject(subject_name)
    check subject_name
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

  def and_my_chosen_year_group_is_selected(year_group)
    expect(page).to have_checked_field(year_group)
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

  def then_see_that_not_known_is_selected
    expect(page).to have_checked_field("Not yet known")
  end

  def and_i_cannot_change_the_phase
    expect(page).not_to have_link("Change Phase")
  end

  def and_i_can_change_the_phase
    expect(page).to have_link("Change Phase")
  end

  def when_i_change_my_phase
    click_link "Change Phase"
  end

  def when_i_change_my_subject
    click_link "Change Subject"
  end

  def when_i_change_my_mentor
    click_link "Change Mentor"
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

  def and_i_see_success_message(message)
    within(".govuk-notification-banner") do
      expect(page).to have_content message
    end
  end

  alias_method :and_i_click_on, :when_i_click_on
  alias_method :and_i_choose_the_subject, :when_i_choose_a_subject
  alias_method :and_i_check_the_subject, :when_i_check_a_subject
  alias_method :then_my_chosen_subject_is_selected, :and_my_chosen_subject_is_selected
  alias_method :then_my_chosen_mentor_is_checked, :and_my_chosen_mentor_is_checked
  alias_method :then_my_chosen_year_group_is_selected, :and_my_chosen_year_group_is_selected
end