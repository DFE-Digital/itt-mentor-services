require "rails_helper"

RSpec.describe "Placements / Placements / Searches filter options for a placements list", :js, service: :placements, type: :system do
  let(:provider) { create(:placements_provider, name: "Provider") }
  let(:london_school) do
    create(
      :placements_school,
      name: "London School",
      latitude: 51.5072178,
      longitude: -0.1275862,
    )
  end
  let(:guildford_school) do
    create(
      :placements_school,
      name: "Guildford School",
      latitude: 51.23622,
      longitude: -0.570409,
    )
  end
  let(:bath_school) do
    create(
      :placements_school,
      name: "Bath School",
      latitude: 51.3781018,
      longitude: -2.3596827,
    )
  end
  let(:primary_maths_subject) { create(:subject, :primary, name: "Primary with mathematics") }
  let(:primary_history_subject) { create(:subject, :primary, name: "Primary with history") }
  let(:primary_geography_subject) { create(:subject, :primary, name: "Primary with geography") }
  let(:london_placement) { create(:placement, school: london_school, subject: primary_maths_subject) }
  let(:guildford_placement) { create(:placement, school: guildford_school, subject: primary_history_subject) }
  let(:bath_placement) { create(:placement, school: bath_school, subject: primary_geography_subject) }

  before do
    london_placement
    guildford_placement
    bath_placement

    given_i_am_signed_in_as_a_placements_user(organisations: [provider])
    when_i_visit_the_placements_index_page
  end

  context "when searching for a subject filter options" do
    it "reduces the number of subject filter options" do
      then_i_see_checkbox_option_for("Subject", "Primary with mathematics")
      and_i_see_checkbox_option_for("Subject", "Primary with history")
      and_i_see_checkbox_option_for("Subject", "Primary with geography")
      when_i_search_the_school_filter_with("Subject", "Primary with geo")
      then_i_see_checkbox_option_for("Subject", "Primary with geography")
      and_i_do_not_see_checkbox_option_for("Subject", "Primary with history")
      and_i_do_not_see_checkbox_option_for("Subject", "Primary with mathematics")
    end

    it "persists selected checkboxes during searches" do
      when_i_check_filter_option("subject-ids", primary_maths_subject.id)
      and_i_search_the_school_filter_with("Subject", "Primary with geo")
      then_i_see_checkbox_option_for("Subject", "Primary with geography")
      and_i_do_not_see_checkbox_option_for("Subject", "Primary with mathematics")
      and_i_check_filter_option("subject-ids", primary_geography_subject.id)
      when_i_search_the_school_filter_with("Subject", nil)
      then_i_see_checkbox_option_for("Subject", "Primary with geography")
      and_i_see_checkbox_option_for("Subject", "Primary with mathematics")
      and_filter_option_is_checked("subject-ids", primary_maths_subject.id)
      and_filter_option_is_checked("subject-ids", primary_geography_subject.id)
    end
  end

  context "when searching for a school filter options" do
    it "reduces the number of school filter options" do
      then_i_see_checkbox_option_for("School", "London School")
      and_i_see_checkbox_option_for("School", "Guildford School")
      and_i_see_checkbox_option_for("School", "Bath School")
      when_i_search_the_school_filter_with("School", "Bath")
      then_i_see_checkbox_option_for("School", "Bath School")
      and_i_do_not_see_checkbox_option_for("School", "London School")
      and_i_do_not_see_checkbox_option_for("School", "Guildford School")
    end

    it "persists selected checkboxes during searches" do
      when_i_check_filter_option("school-ids", london_school.id)
      and_i_search_the_school_filter_with("School", "Bath")
      then_i_see_checkbox_option_for("School", "Bath School")
      and_i_do_not_see_checkbox_option_for("School", "London School")
      and_i_check_filter_option("school-ids", bath_school.id)
      when_i_search_the_school_filter_with("School", nil)
      then_i_see_checkbox_option_for("School", "London School")
      and_i_see_checkbox_option_for("School", "Bath School")
      and_filter_option_is_checked("school-ids", london_school.id)
      and_filter_option_is_checked("school-ids", bath_school.id)
    end
  end

  private

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

  def then_i_see_checkbox_option_for(filter_name, option_name)
    checkboxes = page.find("legend", exact_text: filter_name).sibling(".govuk-checkboxes")
    within(checkboxes) do
      expect(page).to have_content(option_name)
    end
  end
  alias_method :and_i_see_checkbox_option_for, :then_i_see_checkbox_option_for

  def when_i_search_the_school_filter_with(filter_name, option_name)
    fill_in("Filter #{filter_name}", with: option_name)
  end
  alias_method :and_i_search_the_school_filter_with, :when_i_search_the_school_filter_with

  def and_i_do_not_see_checkbox_option_for(filter_name, option_name)
    checkboxes = page.find("legend", exact_text: filter_name).sibling(".govuk-checkboxes")
    within(checkboxes) do
      expect(page).not_to have_content(option_name)
    end
  end

  def when_i_check_filter_option(filter, value)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      normalised_value = [true, false].include?(value) ? value : value.downcase
      page.find("label[for='filters-#{filter}-#{normalised_value}-field']", visible: :all).click
    end
  end
  alias_method :and_i_check_filter_option, :when_i_check_filter_option

  def and_filter_option_is_checked(filter, value)
    filter_options = page.find(".app-filter__options")

    within(filter_options) do
      normalised_value = [true, false].include?(value) ? value : value.downcase
      checkbox = page.find("input#filters-#{filter}-#{normalised_value}-field", visible: :all)
      expect(checkbox).to be_checked
    end
  end
end
