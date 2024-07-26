RSpec.shared_examples "an edit placement wizard", :js do
  let!(:school) { create(:placements_school, name: "School 1", phase: "Primary") }
  let!(:placement) { create(:placement, school:, year_group: :year_1) }
  let(:mentor_1) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let(:mentor_2) { create(:placements_mentor_membership, mentor: create(:placements_mentor), school:).mentor }
  let(:provider_1) { create(:provider, :placements, name: "Provider 1") }
  let(:provider_2) { create(:provider, :placements, name: "Provider 2") }

  context "when the school has no partner providers" do
    it "User is redirected to add a partner provider" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details(
        change_link: "Add a partner provider",
      )
      when_i_click_link(
        text: "Add a partner provider",
        href: public_send("placements_#{context_for_path}_partner_providers_path", school),
      )
      then_i_am_redirected_to_add_a_partner_provider
    end
  end

  context "when the school has partner providers" do
    let(:provider_1_user) { create(:placements_user, providers: [provider_1]) }
    let(:provider_2_user) { create(:placements_user, providers: [provider_2]) }

    before do
      provider_1_user
      provider_2_user
      create(:placements_partnership, school:, provider: provider_1)
      create(:placements_partnership, school:, provider: provider_2)
    end

    context "with no provider" do
      it "User edits the provider", :js do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider(provider_2)
        and_i_click_on("Continue")
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 2",
        )
        and_i_see_success_message("Provider updated")
        and_the_provider_is_notified_they_have_been_assigned_to_the_placement(provider_2_user)
      end

      it "User does not select a provider" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        and_i_click_on("Continue")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end

      it "User edits the provider and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider(provider_2)
        and_i_click_on("Cancel")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end

      it "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
        when_i_click_link(
          text: "Assign a provider",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        and_i_click_on("Back")
        then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details
      end
    end

    context "with a provider" do
      it "User edits the provider" do
        given_the_placement_has_a_provider(provider_1)
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 1",
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        when_i_select_provider(provider_2)
        and_i_click_on("Continue")
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 2",
        )
        and_i_see_success_message("Provider updated")
        and_the_provider_is_notified_they_have_been_removed_from_the_placement(provider_1_user)
        and_the_provider_is_notified_they_have_been_assigned_to_the_placement(provider_2_user)
      end

      it "User does not select a provider" do
        given_the_placement_has_a_provider(provider_1)
        when_i_visit_the_placement_show_page
        then_i_should_see_the_provider_name_in_the_placement_details(
          provider_name: "Provider 1",
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        then_i_should_see_the_edit_provider_page
        when_i_choose_not_yet_known
        and_i_click_on("Continue")
        then_i_see_link(
          text: "Assign a provider",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :provider),
        )
        and_i_see_success_message("Provider updated")
        and_the_provider_is_notified_they_have_been_removed_from_the_placement(provider_1_user)
      end
    end
  end

  context "when I edit the year group" do
    it "User edits the year group" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_year_group_in_the_placement_details(
        year_group_name: "Year 1",
      )
      when_i_click_link(
        text: "Change",
        href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :year_group),
      )
      then_i_should_see_the_edit_year_group_page
      when_i_select_year("Year 4")
      and_i_click_on("Continue")
      then_i_should_see_the_year_group_in_the_placement_details(
        year_group_name: "Year 4",
      )
      and_i_see_success_message("Year Group updated")
    end
  end

  context "when the school has no mentors" do
    it "User is redirected to add a mentor" do
      when_i_visit_the_placement_show_page
      then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details(
        change_link: "Add a mentor",
      )
      when_i_click_link(
        text: "Add a mentor",
        href: public_send("placements_#{context_for_path}_mentors_path", school),
      )
      then_i_am_redirected_to_add_a_mentor
    end
  end

  context "when the school has mentors" do
    before do
      mentor_1
      mentor_2
    end

    context "with no mentors" do
      it "User edits the mentors" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_uncheck("Not yet known")
        when_i_select_mentor_2
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_name_in_the_placement_details(mentor_name: mentor_2.full_name)
        and_i_see_success_message("Mentors updated")
      end

      it "User does not select a mentor" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        when_i_uncheck("Not yet known")
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Continue")
        then_i_should_see_an_error_message
      end

      it "User edits the mentor and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Cancel")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      end

      it "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        when_i_click_link(
          text: "Select a mentor",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Back")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
      end
    end

    context "with mentors" do
      let(:placement) { create(:placement, school:, provider: provider_1, mentors: [mentor_1]) }

      it "User edits the mentors" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_2.full_name,
        )
        and_i_see_success_message("Mentors updated")
      end

      it "User does not select a mentor" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_uncheck(mentor_1.full_name)
        and_i_uncheck("Not yet known")
        and_i_click_on("Continue")
        then_i_should_see_an_error_message
      end

      it "User edits the mentor and cancels" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_mentor_2
        and_i_click_on("Cancel")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
      end

      it "User clicks on back" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        and_i_click_on("Back")
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
      end

      it "User selects not yet known" do
        when_i_visit_the_placement_show_page
        then_i_should_see_the_mentor_name_in_the_placement_details(
          mentor_name: mentor_1.full_name,
        )
        when_i_click_link(
          text: "Change",
          href: public_send("new_edit_placement_placements_#{context_for_path}_placement_path", school, placement, step: :mentors),
        )
        then_i_should_see_the_edit_mentors_page
        when_i_select_not_yet_known
        and_i_click_on("Continue")
        then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details
        and_i_see_success_message("Mentors updated")
      end
    end
  end

  private

  def and_i_visit_the_sign_in_path
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def then_i_should_see_the_mentor_name_in_the_placement_details(
    mentor_name:, change_link: "Change"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(mentor_name)
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_the_mentor_is_not_yet_known_in_the_placement_details(
    change_link: "Select a mentor"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_an_error_message
    within(".govuk-error-summary__title") do
      expect(page).to have_content("There is a problem")
    end

    within(".govuk-error-summary__body") do
      expect(page).to have_content("Select a mentor or not yet known")
    end
  end

  def when_i_select_not_yet_known
    uncheck mentor_1.full_name
    check "Not yet known"
  end

  def when_i_click_on(text)
    click_on(text)
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_click_link(text:, href:)
    click_link text, href:
  end

  def then_i_should_see_the_edit_mentors_page
    expect(page).to have_content("Manage a placement")
    expect(page).to have_content("Mentor")
  end

  def when_i_select_mentor_2
    check mentor_2.full_name
  end

  def then_i_see_link(text:, href:)
    expect(page).to have_link(text, href:)
  end

  def when_i_uncheck(text)
    uncheck(text)
  end

  def and_i_see_success_message(message)
    within(".govuk-notification-banner") do
      expect(page).to have_content message
    end
  end

  def then_i_should_see_the_provider_is_not_known_yet_in_the_placement_details(
    change_link: "Assign a provider"
  )
    within(".govuk-summary-list") do
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_the_edit_provider_page
    expect(page).to have_content("Manage a placement")
    expect(page).to have_content("Provider")
  end

  def when_i_select_provider(provider)
    choose provider.name
  end

  def then_i_should_see_the_provider_name_in_the_placement_details(provider_name:, change_link: "Change")
    within(".govuk-summary-list") do
      expect(page).to have_content(provider_name)
      expect(page).to have_content(change_link)
    end
  end

  def given_the_placement_has_a_provider(provider)
    placement.update!(provider:)
  end

  def when_i_choose_not_yet_known
    choose "Not yet known"
  end

  def then_i_should_see_the_year_group_in_the_placement_details(year_group_name:, change_link: "Change")
    within(".govuk-summary-list") do
      expect(page).to have_content(year_group_name)
      expect(page).to have_content(change_link)
    end
  end

  def then_i_should_see_the_edit_year_group_page
    expect(page).to have_content("Manage a placement")
    expect(page).to have_content("Year group")
  end

  def when_i_select_year(year)
    choose year
  end

  def and_the_provider_is_notified_they_have_been_assigned_to_the_placement(user)
    and_the_provider_is_notified(user, "#{school.name} wants you to place a trainee with them")
  end

  def and_the_provider_is_notified_they_have_been_removed_from_the_placement(user)
    and_the_provider_is_notified(user, "#{school.name} has removed you from a placement")
  end

  def and_the_provider_is_notified(user, subject)
    ActionMailer::Base.deliveries.find do |delivery|
      delivery.to.include?(user.email) &&
        delivery.subject == subject
    end
  end

  alias_method :and_i_click_on, :when_i_click_on
  alias_method :and_i_uncheck, :when_i_uncheck
end
