require "rails_helper"

RSpec.describe "Provider user filters placements by schools I work with", service: :placements, type: :system do
  scenario do
    given_that_placements_exist
    and_i_am_signed_in

    when_i_am_on_the_placements_index_page
    then_i_see_all_placements
    and_i_see_the_schools_i_work_with_filter

    when_i_select_only_show_placements_from_schools_i_work_with_from_the_schools_i_work_with_filter
    and_i_click_on_apply_filters
    then_i_see_the_school_i_work_with_placement
    and_i_do_not_see_the_school_i_do_not_work_with_placement
    and_i_see_my_selected_schools_i_work_with_filter

    when_i_click_on_the_school_i_work_with_filter_tag
    then_i_see_all_placements
    and_i_do_not_see_any_selected_schools_i_work_with_filters
  end

  private

  def given_that_placements_exist
    @school_i_work_with = build(:placements_school, phase: "Primary", name: "Springfield Elementary")
    @school_i_work_with_subject = build(:subject, name: "Primary with mathematics", subject_area: "primary")
    _school_i_work_with_placement = create(:placement, school: @school_i_work_with,
                                                       subject: @school_i_work_with_subject)

    @provider = build(:placements_provider, name: "Aes Sedai Trust", partner_schools: [@school_i_work_with])

    @school_i_do_not_work_with = build(:placements_school, phase: "Secondary", name: "Hogwarts")
    @school_i_do_not_work_with_subject = build(:subject, name: "Primary with english", subject_area: "secondary")
    _school_i_do_not_work_with_placement = create(:placement, school: @school_i_do_not_work_with,
                                                              subject: @school_i_do_not_work_with_subject)
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_am_on_the_placements_index_page
    expect(page).to have_title("Find placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Find placements")
    expect(page).to have_h2("Filter")
  end

  def then_i_see_all_placements
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
    expect(page).to have_h2("Primary with english – Hogwarts")
  end

  def and_i_see_the_schools_i_work_with_filter
    expect(page).to have_element(:legend, text: "Schools I work with", class: "govuk-fieldset__legend",
                                          match: :prefer_exact)
    expect(page).to have_field("Only show placements from schools I work with", type: "checkbox", checked: false)
  end

  def when_i_select_only_show_placements_from_schools_i_work_with_from_the_schools_i_work_with_filter
    check "Only show placements from schools I work with"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def then_i_see_the_school_i_work_with_placement
    expect(page).to have_h2("Primary with mathematics – Springfield Elementary")
  end

  def and_i_do_not_see_the_school_i_do_not_work_with_placement
    expect(page).not_to have_h2("Primary with english– Hogwarts")
  end

  def and_i_see_my_selected_schools_i_work_with_filter
    expect(page).to have_filter_tag("Schools I work with")
    expect(page).to have_checked_field("Only show placements from schools I work with")
  end

  def when_i_click_on_the_school_i_work_with_filter_tag
    within ".app-filter-tags" do
      click_on "Schools I work with"
    end
  end

  def and_i_do_not_see_any_selected_schools_i_work_with_filters
    expect(page).not_to have_filter_tag("Schools I work with")
    expect(page).not_to have_checked_field("Only show placements from schools I work with")
  end
end
