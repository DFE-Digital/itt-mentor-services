require "rails_helper"

RSpec.describe "Placements / Providers / Placements / View dynamic filters for placements",
               type: :system,
               service: :placements,
               js: true do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let(:primary_school) { create(:placements_school, name: "Primary School 1", phase: "Primary") }
  let(:secondary_school) { create(:placements_school, name: "Secondary School 1", phase: "Secondary") }
  let(:all_through_school) { create(:placements_school, name: "All-through School 1", phase: "All-through") }
  let(:primary_subject) { create(:subject, :primary, name: "Primary Subject") }
  let(:secondary_subject) { create(:subject, :secondary, name: "Secondary Subject") }

  before do
    given_i_sign_in_as_patricia
    primary_school
    secondary_school
    all_through_school
    primary_subject
    secondary_subject
  end

  scenario "User can dynamically filter Primary schools and subjects" do
    when_i_visit_the_placements_index_page
    # Default setting no filter options checked, should show all filter options
    then_i_can_see_phase_filter_option_not_checked("Primary")
    and_i_can_see_phase_filter_option_not_checked("Secondary")
    and_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_see_subject_filter_option("Secondary Subject")
    when_i_check_phase_filter_option("Primary")
    then_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_not_see_school_filter_option("Secondary School 1")
    and_i_can_not_see_subject_filter_option("Secondary Subject")
  end

  scenario "User can dynamically filter Secondary schools and subjects" do
    when_i_visit_the_placements_index_page
    # Default setting no filter options checked, should show all filter options
    then_i_can_see_phase_filter_option_not_checked("Primary")
    and_i_can_see_phase_filter_option_not_checked("Secondary")
    and_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_see_subject_filter_option("Secondary Subject")
    when_i_check_phase_filter_option("Secondary")
    then_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Secondary Subject")
    and_i_can_not_see_school_filter_option("Primary School 1")
    and_i_can_not_see_subject_filter_option("Primary Subject")
  end

  scenario "User can dynamically filter both Primary and Secondary schools and subjects" do
    when_i_visit_the_placements_index_page
    # Default setting no filter options checked, should show all filter options
    then_i_can_see_phase_filter_option_not_checked("Primary")
    and_i_can_see_phase_filter_option_not_checked("Secondary")
    and_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_see_subject_filter_option("Secondary Subject")
    when_i_check_phase_filter_option("Primary")
    and_i_check_phase_filter_option("Secondary")
    then_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_see_subject_filter_option("Secondary Subject")
  end

  scenario "User can see dynamic filters pre-set when filters were previously applied (Primary phase)" do
    when_i_visit_the_placements_index_page({ filters: { school_phases: %w[Primary] } })
    then_i_can_see_phase_filter_option_checked("Primary")
    and_i_can_see_phase_filter_option_not_checked("Secondary")
    and_i_can_see_school_filter_option("Primary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Primary Subject")
    and_i_can_not_see_school_filter_option("Secondary School 1")
    and_i_can_not_see_subject_filter_option("Secondary Subject")
  end

  scenario "User can see dynamic filters pre-set when filters were previously applied (Secondary phase)" do
    when_i_visit_the_placements_index_page({ filters: { school_phases: %w[Secondary] } })
    then_i_can_see_phase_filter_option_checked("Secondary")
    and_i_can_see_phase_filter_option_not_checked("Primary")
    and_i_can_see_school_filter_option("Secondary School 1")
    and_i_can_see_school_filter_option("All-through School 1")
    and_i_can_see_subject_filter_option("Secondary Subject")
    and_i_can_not_see_school_filter_option("Primary School 1")
    and_i_can_not_see_subject_filter_option("Primary Subject")
  end

  private

  def given_i_sign_in_as_patricia
    user = create(:placements_user, :patricia)
    create(:user_membership, user:, organisation: provider)
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def when_i_visit_the_placements_index_page(params = {})
    visit placements_provider_placements_path(provider, params)

    expect_placements_to_be_selected_in_primary_navigation
  end

  def expect_placements_to_be_selected_in_primary_navigation
    nav = page.find(".app-primary-navigation__nav")

    within(nav) do
      expect(page).to have_link "Placements", current: "page"
      expect(page).to have_link "Partner schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_can_see_school_filter_option(school_name)
    then_i_can_see_option(school_name)
  end
  alias_method :and_i_can_see_school_filter_option, :then_i_can_see_school_filter_option

  def then_i_can_see_subject_filter_option(subject_name)
    then_i_can_see_option(subject_name)
  end
  alias_method :and_i_can_see_subject_filter_option, :then_i_can_see_subject_filter_option

  def then_i_can_see_option(option_text)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      expect(page).to have_content(option_text)
    end
  end

  def when_i_check_phase_filter_option(phase_text)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      page.find("#filters-school-phases-#{phase_text.downcase}-field", visible: :all).check
    end
  end
  alias_method :and_i_check_phase_filter_option, :when_i_check_phase_filter_option

  def then_i_can_not_see_school_filter_option(school_name)
    then_i_can_not_see_option(school_name)
  end
  alias_method :and_i_can_not_see_school_filter_option, :then_i_can_not_see_school_filter_option

  def then_i_can_not_see_subject_filter_option(subject_name)
    then_i_can_not_see_option(subject_name)
  end
  alias_method :and_i_can_not_see_subject_filter_option, :then_i_can_not_see_subject_filter_option

  def then_i_can_not_see_option(option_text)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      expect(page).not_to have_content(option_text)
    end
  end

  def then_i_can_see_phase_filter_option_checked(phase_text)
    then_phase_filter_option(phase_text, true)
  end
  alias_method :and_i_can_see_phase_filter_option_checked, :then_i_can_see_phase_filter_option_checked

  def then_i_can_see_phase_filter_option_not_checked(phase_text)
    then_phase_filter_option(phase_text, false)
  end
  alias_method :and_i_can_see_phase_filter_option_not_checked, :then_i_can_see_phase_filter_option_not_checked

  def then_phase_filter_option(phase_text, checked)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      phase_option = page.find("#filters-school-phases-#{phase_text.downcase}-field", visible: :all)
      expect(phase_option.checked?).to eq(checked)
    end
  end
end
