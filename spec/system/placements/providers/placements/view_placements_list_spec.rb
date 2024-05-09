require "rails_helper"

RSpec.describe "Placements / Providers / Placements / View placements list",
               type: :system,
               service: :placements,
               js: true do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let!(:primary_school) do
    create(
      :placements_school,
      phase: "Primary",
      name: "Primary School",
      type_of_establishment: "Free school",
    )
  end
  let!(:secondary_school) do
    create(
      :placements_school,
      phase: "Secondary",
      name: "Secondary School",
      type_of_establishment: "Community school",
    )
  end
  let!(:subject_1) { create(:subject, name: "Primary with mathematics") }
  let!(:subject_2) { create(:subject, name: "Chemistry") }
  let(:placement_1) { create(:placement, subjects: [subject_1], school: primary_school) }
  let(:placement_2) { create(:placement, subjects: [subject_2], school: secondary_school, provider: create(:placements_provider)) }

  before do
    given_i_sign_in_as_patricia
  end

  scenario "User views all placements page, when no placements exist" do
    when_i_visit_the_placements_index_page
    then_i_see_the_empty_state
  end

  context "when placements exist" do
    before do
      placement_1
      placement_2
    end

    scenario "User can view all placements" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    scenario "User can filter placements by availability" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("available", "true")
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_placement_1
      and_i_cannot_see_a_placement_for_placement_2
    end

    scenario "User can filter placements by partner school" do
      given_a_partnership_exists_between(provider, primary_school)
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("partner-school-ids", primary_school.id)
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    scenario "User can filter placements by school" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("school-ids", primary_school.id)
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    scenario "User can filter placements by subject" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("subject-ids", subject_1.id)
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    scenario "User can filter placements by school type" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("school-types", "free-school")
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    context "when a filter is pre-selected in the URL params" do
      scenario "User can remove the available filter" do
        when_i_visit_the_placements_index_page({ filters: { available: %w[true] } })
        then_i_can_see_a_placement_for_placement_1
        and_i_cannot_see_a_placement_for_placement_2
        and_i_can_see_a_preset_filter("Placements Available", "Available")
        when_i_click_to_remove_filter("Placements Available", "Available")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can remove a partner school filter" do
        given_a_partnership_exists_between(provider, primary_school)
        when_i_visit_the_placements_index_page({ filters: { partner_school_ids: [primary_school.id] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Partner school", "Primary School")
        when_i_click_to_remove_filter("Partner school", "Primary School")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can remove a school filter" do
        when_i_visit_the_placements_index_page({ filters: { school_ids: [primary_school.id] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("School", "Primary School")
        when_i_click_to_remove_filter("School", "Primary School")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can remove a subject filter" do
        when_i_visit_the_placements_index_page({ filters: { subject_ids: [subject_1.id] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Subject", "Primary with mathematics")
        when_i_click_to_remove_filter("Subject", "Primary with mathematics")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can remove a school type filter" do
        when_i_visit_the_placements_index_page({ filters: { school_types: ["Free school"] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("School type", "Free school")
        when_i_click_to_remove_filter("School type", "Free school")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can clear all filters" do
        when_i_visit_the_placements_index_page(
          {
            filters: {
              partner_school_ids: [primary_school.id],
              school_ids: [primary_school.id],
              subject_ids: [subject_1.id],
              school_types: ["Free school"],
            },
          },
        )
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Partner school", "Primary School")
        and_i_can_see_a_preset_filter("School", "Primary School")
        and_i_can_see_a_preset_filter("Subject", "Primary with mathematics")
        and_i_can_see_a_preset_filter("School type", "Free school")
        when_i_click_on("Clear filters")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end
    end
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

  def then_i_see_the_empty_state
    expect(page).to have_content("There are no results for the selected filter.")
  end

  def then_i_can_see_a_placement_for_school_and_subject(school_name, subject_name)
    expect(page).to have_content("#{school_name}\n#{subject_name}")
  end
  alias_method :and_i_can_see_a_placement_for_school_and_subject,
               :then_i_can_see_a_placement_for_school_and_subject

  def then_i_can_not_see_a_placement_for_school_and_subject(school_name, subject_name)
    expect(page).not_to have_content("#{school_name}\n#{subject_name}")
  end
  alias_method :and_i_can_not_see_a_placement_for_school_and_subject,
               :then_i_can_not_see_a_placement_for_school_and_subject

  def when_i_check_filter_option(filter, value)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      page.find("label[for='filters-#{filter}-#{value.downcase}-field']", visible: :all).click
    end
  end

  def then_i_can_see_a_preset_filter(filter, value)
    selected_filters = page.find(".app-filter-layout__selected")

    within(selected_filters) do
      expect(page).to have_content(filter)
      expect(page).to have_content(value)
    end
  end
  alias_method :and_i_can_see_a_preset_filter, :then_i_can_see_a_preset_filter

  def when_i_click_to_remove_filter(_filter, value)
    selected_filters = page.find(".app-filter-layout__selected")

    within(selected_filters) do
      click_on value
    end
  end

  def then_i_can_not_see_any_selected_filters
    expect(page).not_to have_content("Selected filters")
  end
  alias_method :and_i_can_not_see_any_selected_filters,
               :then_i_can_not_see_any_selected_filters

  def given_a_partnership_exists_between(provider, school)
    Placements::Partnership.create!(provider:, school:)
  end

  def then_i_can_see_a_placement_for_placement_1
    expect(page).to have_content("Primary School\nPrimary with mathematics")
  end

  def and_i_cannot_see_a_placement_for_placement_2
    expect(page).not_to have_content("Secondary School\nChemistry")
  end
end
