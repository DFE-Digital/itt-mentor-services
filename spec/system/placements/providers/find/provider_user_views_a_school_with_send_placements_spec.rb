require "rails_helper"

RSpec.describe "Provider user views a school with previous, filled and unfilled placements", service: :placements, type: :system do
  scenario do
    given_that_schools_exist
    and_i_am_signed_in

    when_i_navigate_to_the_find_schools_page
    then_i_see_the_find_schools_page
    and_i_see_shelbyville_high_school_is_offering_send_placements
    and_i_see_springfield_elementary_school_is_not_offering_send_placements
    and_i_see_hogwarts_is_offering_send_placements
    and_i_see_ogdenville_elementary_school_is_not_offering_send_placements

    when_i_click_on_shelbyville_high_school
    then_i_see_the_shelbyville_high_school_show_page
    and_i_see_an_unfilled_placement_for_send_key_stage_1
    and_i_see_an_filled_placement_for_send_key_stage_5

    when_i_click_on_back
    and_i_click_on_hogwarts
    then_i_see_the_hogwarts_show_page
    and_i_see_hogwarts_will_potentially_offer_send_placements
  end

  private

  def given_that_schools_exist
    academic_year = Placements::AcademicYear.current.next
    @provider = build(:placements_provider, name: "Aes Sedai Trust")

    @key_stage_1 = build(:key_stage, name: "Key stage 1")
    @key_stage_5 = build(:key_stage, name: "Key stage 5")

    @english = build(:subject, :secondary, name: "English")
    @science = build(:subject, :secondary, name: "Science")

    send_placements_school_hosting_interest = build(:hosting_interest, academic_year:)
    @send_placements_school = create(
      :placements_school,
      :secondary,
      name: "Shelbyville High School",
      hosting_interests: [send_placements_school_hosting_interest],
    )
    create(
      :placement,
      :send,
      academic_year:,
      key_stage: @key_stage_1,
      school: @send_placements_school,
    )
    create(
      :placement,
      :send,
      academic_year:,
      key_stage: @key_stage_5,
      school: @send_placements_school,
      provider: @provider,
    )

    non_send_placements_school_hosting_interest = build(:hosting_interest, academic_year:)
    @non_send_placements_school = create(
      :placements_school,
      :secondary,
      name: "Springfield Elementary School",
      hosting_interests: [non_send_placements_school_hosting_interest],
    )
    create(:placement, academic_year:, subject: @english, school: @non_send_placements_school)
    create(:placement, academic_year:, subject: @science, school: @non_send_placements_school)

    potential_send_placement_school_hosting_interest = build(
      :hosting_interest,
      academic_year:,
      appetite: "interested",
    )
    @potential_send_placement_school = create(
      :placements_school,
      :secondary,
      name: "Hogwarts",
      hosting_interests: [potential_send_placement_school_hosting_interest],
      potential_placement_details: { "phase" => { "phases" => %w[SEND] },
                                     "key_stage_selection" => { "key_stage_ids" => [@key_stage_1.id, @key_stage_5.id] },
                                     "key_stage_placement_quantity" => { "key_stage_1" => 2, "key_stage_5" => 1 } },
    )

    potential_non_send_placement_school_hosting_interest = build(
      :hosting_interest,
      academic_year:,
      appetite: "interested",
    )
    @potential_non_send_placement_school = create(
      :placements_school,
      :secondary,
      name: "Ogdenville Elementary School",
      hosting_interests: [potential_non_send_placement_school_hosting_interest],
      potential_placement_details: { "phase" => { "phases" => %w[Primary Secondary] },
                                     "year_group_selection" => { "year_groups" => ["Year 1, Year 2"] },
                                     "secondary_placement_quantity" => { "biology" => 1, "chemistry" => 2 },
                                     "year_group_placement_quantity" => { "year_1" => 2, "year_2" => 1 } },
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@provider])
  end

  def when_i_navigate_to_the_find_schools_page
    within primary_navigation do
      click_on "Find"
    end
  end

  def then_i_see_the_find_schools_page
    expect(page).to have_title("Find schools hosting placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Find schools hosting placements")
    expect(page).to have_h2("Filter")
  end

  def and_i_see_shelbyville_high_school_is_offering_send_placements
    shelbyville_result = page.find(".app-search-results__item", text: "Shelbyville High School")
    within(shelbyville_result) do
      expect(page).to have_tag("Placements available", "green")
      expect(page).to have_result_detail_row("SEND placements", "Yes")
    end
  end

  def and_i_see_springfield_elementary_school_is_not_offering_send_placements
    springfield_result = page.find(".app-search-results__item", text: "Springfield Elementary School")
    within(springfield_result) do
      expect(page).to have_tag("Placements available", "green")
      expect(page).to have_result_detail_row("SEND placements", "No")
    end
  end

  def and_i_see_hogwarts_is_offering_send_placements
    hogwarts_result = page.find(".app-search-results__item", text: "Hogwarts")
    within(hogwarts_result) do
      expect(page).to have_tag("May offer placements", "yellow")
      expect(page).to have_result_detail_row("SEND placements", "Yes")
    end
  end

  def and_i_see_ogdenville_elementary_school_is_not_offering_send_placements
    ogdenville_result = page.find(".app-search-results__item", text: "Ogdenville Elementary School")
    within(ogdenville_result) do
      expect(page).to have_tag("May offer placements", "yellow")
      expect(page).to have_result_detail_row("SEND placements", "No")
    end
  end

  def when_i_click_on_shelbyville_high_school
    click_on "Shelbyville High School"
  end

  def then_i_see_the_shelbyville_high_school_show_page
    expect(page).to have_title("Shelbyville High School - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Shelbyville High School")
    expect(page).to have_tag("Placements available", "green")
  end

  def and_i_see_an_unfilled_placement_for_send_key_stage_1
    expect(page).to have_h2("1 unfilled placement")
    expect(page).to have_table_row({
      "Subject" => "SEND (Key stage 1)",
      "Expected date" => "Any time in the academic year",
    })
  end

  def and_i_see_an_filled_placement_for_send_key_stage_5
    expect(page).to have_h2("1 filled placement")
    expect(page).to have_table_row({
      "Subject" => "SEND (Key stage 5)",
      "Expected date" => "Any time in the academic year",
    })
  end

  def when_i_click_on_back
    click_on "Back"
  end

  def and_i_click_on_hogwarts
    click_on "Hogwarts"
  end

  def then_i_see_the_hogwarts_show_page
    expect(page).to have_title("Hogwarts - Find - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Find")
    expect(page).to have_h1("Hogwarts")
    expect(page).to have_tag("May offer placements", "yellow")
  end

  def and_i_see_hogwarts_will_potentially_offer_send_placements
    expect(page).to have_summary_list_row("Phase", "SEND")
    expect(page).to have_h2("Potential SEND placements")
    expect(page).to have_summary_list_row("Key stage", "Number of placements")
    expect(page).to have_summary_list_row("Key Stage 1", "2")
    expect(page).to have_summary_list_row("Key Stage 5", "1")
  end
end
