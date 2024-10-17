require "rails_helper"

RSpec.describe "Placements / Placements / View placements list",
               service: :placements, type: :system do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let!(:primary_school) do
    create(
      :placements_school,
      phase: "Primary",
      name: "Primary School",
      group: "Free Schools",
      latitude: 51.5072178,
      longitude: -0.1275862,
    )
  end
  let!(:secondary_school) do
    create(
      :placements_school,
      phase: "Secondary",
      name: "Secondary School",
      group: "Local authority maintained schools",
      latitude: 53.9614205,
      longitude: -1.0739108,
    )
  end
  let!(:subject_1) { create(:subject, name: "Primary with mathematics") }
  let!(:subject_2) { create(:subject, name: "Chemistry") }
  let!(:subject_3) { create(:subject, name: "Physics") }
  let(:summer_term) { build(:placements_term, :summer) }
  let(:autumn_term) { build(:placements_term, :autumn) }
  let(:placement_1) { create(:placement, subject: subject_1, school: primary_school, year_group: :year_1, terms: [summer_term]) }
  let(:placement_2) { create(:placement, subject: subject_2, school: secondary_school, terms: [autumn_term]) }
  let(:placement_3) { create(:placement, subject: subject_3, school: secondary_school, provider: build(:placements_provider)) }

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
      placement_3
    end

    scenario "User can view available placements by default" do
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Physics")
      and_i_can_see_the_status_tag_for_placement_1
    end

    scenario "User can view placements assigned to them" do
      when_i_visit_the_placements_index_page
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Physics")
      placement_3.update!(provider:)
      and_i_check_filter_option("placements-to-show", "assigned-to-me")
      and_i_click_on("Apply filters")
      and_i_can_not_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      then_i_can_see_a_placement_for_school_and_subject("Secondary School", "Physics")
    end

    scenario "User can view all placements" do
      when_i_visit_the_placements_index_page
      and_i_check_filter_option("placements-to-show", "all-placements")
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      and_i_can_see_the_status_tag_for_placement_1
      and_i_can_see_the_status_tag_for_placement_2
    end

    scenario "User can filter placements by term" do
      when_i_visit_the_placements_index_page
      # Show all placements
      and_i_check_filter_option("placements-to-show", "all-placements")
      and_i_click_on("Apply filters")
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Physics")
      when_i_check_filter_option("term-ids", summer_term.id)
      and_i_click_on("Apply filters")
      # This placement has the summer term we're filtering for
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      # This placement has no terms (aka any term), so should always be visible
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Physics")
      # This placement has the autumn term, and should not be visible
      and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
    end

    scenario "User can filter placements by partner school" do
      given_a_partnership_exists_between(provider, primary_school)
      when_i_visit_the_placements_index_page
      then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
      and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      when_i_check_filter_option("only-partner-schools", true)
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

    context "when placements have additional subjects" do
      let!(:parent_subject) { build(:subject, name: "Modern Foreign Languages") }
      let!(:additional_subject) { create(:subject, name: "French", parent_subject:) }
      let!(:additional_subject_2) { create(:subject, name: "Spanish", parent_subject:) }
      let(:additional_subject_placement) do
        create(:placement, subject: parent_subject, school: secondary_school,
                           additional_subjects: [additional_subject, additional_subject_2])
      end

      before { additional_subject_placement }

      scenario "User can filter placements by additional subjects" do
        when_i_visit_the_placements_index_page
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "French and Spanish")
        when_i_check_filter_option("subject-ids", additional_subject.id)
        and_i_click_on("Apply filters")
        then_i_can_see_a_placement_for_school_and_subject("Secondary School", "French and Spanish")
        and_i_can_not_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      end

      scenario "User can filter placements by subject and additional subjects together" do
        when_i_visit_the_placements_index_page
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "French")
        when_i_check_filter_option("subject-ids", additional_subject.id)
        when_i_check_filter_option("subject-ids", subject_1.id)
        and_i_click_on("Apply filters")
        then_i_can_see_a_placement_for_school_and_subject("Secondary School", "French")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
      end
    end

    context "when a filter is pre-selected in the URL params" do
      scenario "User can remove a terms filter" do
        when_i_visit_the_placements_index_page({ filters: { term_ids: [summer_term.id] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Expected date", "Summer term")
        when_i_click_to_remove_filter("Expected date", "Summer term")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can remove a schools I work with filter" do
        given_a_partnership_exists_between(provider, primary_school)
        when_i_visit_the_placements_index_page({ filters: { only_partner_schools: true } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Schools I work with", "Schools I work with")
        when_i_click_to_remove_filter("Schools I work with", "Schools I work with")
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

      scenario "User can remove a year group filter" do
        when_i_visit_the_placements_index_page({ filters: { year_groups: [:year_1] } })
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Primary year group", "Year 1")
        when_i_click_to_remove_filter("Primary year group", "Year 1")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end

      scenario "User can clear all filters" do
        given_a_partnership_exists_between(provider, primary_school)
        when_i_visit_the_placements_index_page(
          {
            filters: {
              only_partner_schools: true,
              school_ids: [primary_school.id],
              subject_ids: [subject_1.id],
              year_groups: [:year_1],
              term_ids: [summer_term.id],
            },
          },
        )
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_a_preset_filter("Schools I work with", "Schools I work with")
        and_i_can_see_a_preset_filter("School", "Primary School")
        and_i_can_see_a_preset_filter("Subject", "Primary with mathematics")
        and_i_can_see_a_preset_filter("Primary year group", "Year 1")
        and_i_can_see_a_preset_filter("Expected date", "Summer term")
        when_i_click_on("Clear filters")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_not_see_any_selected_filters
      end
    end

    context "when a search location has been pre-entered" do
      before { stub_london_geocoder_search }

      scenario "User can filter placements by school, and the location search persists" do
        when_i_visit_the_placements_index_page({ search_location: "London" })
        and_i_check_filter_option("school-ids", primary_school.id)
        and_i_click_on("Apply filters")
        then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
        and_i_can_not_see_a_placement_for_school_and_subject("Secondary School", "Chemistry")
        and_i_can_see_search_location_is_set_as("London")
        and_i_see_placements_for(school_name: "Primary School", list_item: 0, distance: 0.0)
      end

      context "when a filter is pre-selected in the URL params" do
        scenario "User can remove a school filter, and the location search persists" do
          when_i_visit_the_placements_index_page(
            { search_location: "London", filters: { school_ids: [primary_school.id] } },
          )
          and_i_can_see_a_preset_filter("School", "Primary School")
          when_i_click_to_remove_filter("School", "Primary School")
          then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
          and_i_can_see_search_location_is_set_as("London")
          and_i_see_placements_for(school_name: "Primary School", list_item: 0, distance: 0.0)
        end

        scenario "User can clear all filters, and the location search persists" do
          when_i_visit_the_placements_index_page(
            { search_location: "London", filters: { school_ids: [primary_school.id] } },
          )
          and_i_can_see_a_preset_filter("School", "Primary School")
          when_i_click_on("Clear filters")
          then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
          and_i_can_not_see_any_selected_filters
          and_i_can_see_search_location_is_set_as("London")
          and_i_see_placements_for(school_name: "Primary School", list_item: 0, distance: 0.0)
        end

        scenario "User can clear the location search, and the filters persist" do
          when_i_visit_the_placements_index_page(
            { search_location: "London", filters: { school_ids: [primary_school.id] } },
          )
          and_i_can_see_search_location_is_set_as("London")
          and_i_can_see_a_preset_filter("School", "Primary School")
          when_i_click_on("Clear search")
          then_i_can_see_a_placement_for_school_and_subject("Primary School", "Primary with mathematics")
          and_i_can_see_a_preset_filter("School", "Primary School")
          and_i_can_see_search_location_is_set_as(nil)
        end
      end
    end

    context "when a user views a placement and returns to the index page" do
      before do
        stub_london_geocoder_search
        create_list(:placement, 30, subject: subject_1, school: primary_school)
      end

      scenario "User filters are preserved when using the back button" do
        when_i_visit_the_placements_index_page({ search_location: "London" })
        when_i_check_filter_option("subject-ids", subject_1.id)
        and_i_click_on("Apply filters")
        and_i_navigate_to("2")
        when_i_click_on_the_first_placement
        and_i_click_on("Back")
        then_i_can_see_a_preset_filter("Subject", subject_1.name)
        and_i_can_see_search_location_is_set_as("London")
        and_the_pagination_remains_selected("2")
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
      expect(page).to have_link "Schools", current: "false"
      expect(page).to have_link "Users", current: "false"
      expect(page).to have_link "Organisation details", current: "false"
    end
  end

  def then_i_see_the_empty_state
    expect(page).to have_content I18n.t("placements.providers.placements.index.no_results")
  end

  def then_i_can_see_a_placement_for_school_and_subject(school_name, subject_name)
    expect(page).to have_content("#{school_name} #{subject_name}")
  end

  alias_method :and_i_can_see_a_placement_for_school_and_subject,
               :then_i_can_see_a_placement_for_school_and_subject

  def then_i_can_not_see_a_placement_for_school_and_subject(school_name, subject_name)
    expect(page).not_to have_content("#{school_name} #{subject_name}")
  end

  alias_method :and_i_can_not_see_a_placement_for_school_and_subject,
               :then_i_can_not_see_a_placement_for_school_and_subject

  def when_i_check_filter_option(filter, value)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      normalised_value = [true, false].include?(value) ? value : value.downcase
      page.find("label[for='filters-#{filter}-#{normalised_value}-field']", visible: :all).click
    end
  end

  alias_method :and_i_check_filter_option, :when_i_check_filter_option

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

  def and_i_can_see_the_status_tag_for_placement_1
    all(".govuk-tag--turquoise").first do
      expect(page).to have_text("Available")
    end
  end

  def and_i_can_see_the_status_tag_for_placement_2
    within(".govuk-tag--orange") do
      expect(page).to have_text("Unavailable")
    end
  end

  def and_i_can_see_search_location_is_set_as(search_location)
    expect(page.find("#search-location-field").value).to eq(search_location)
  end

  def then_i_see_placements_for(school_name:, list_item:, distance:)
    within(".app-search-results") do
      placement_div = page.all(".app-search-results__item")[list_item]
      expect(placement_div).to have_content(school_name)
      expect(placement_div).to have_content("#{distance} miles")
    end
  end

  alias_method :and_i_see_placements_for, :then_i_see_placements_for

  def and_i_navigate_to(text)
    click_link(text)
  end

  def when_i_click_on_the_first_placement
    first(".app-search-results__item").click_link("Primary with mathematics")
  end

  def and_the_pagination_remains_selected(text)
    expect(find(".govuk-pagination__item--current")).to have_content(text)
  end

  def stub_london_geocoder_search
    geocoder_results = instance_double("geocoder_results")
    geocoder_result = instance_double("geocoder_result")
    allow(geocoder_results).to receive(:first).and_return(geocoder_result)
    allow(geocoder_result).to receive(:coordinates).and_return([51.5072178, -0.1275862])
    allow(Geocoder).to receive(:search).and_return(geocoder_results)
  end
end
