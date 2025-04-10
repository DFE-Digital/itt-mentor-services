require "rails_helper"

RSpec.describe "Support user views a schools mentors",
               service: :placements,
               type: :system do
  scenario do
    given_a_school_exists_with_mentors
    and_i_am_signed_in

    when_i_am_on_the_organisations_index_page
    and_i_select_springfield_elementary
    and_i_navigate_to_mentors
    then_i_see_the_mentors_at_your_school_page
    and_i_see_mentor_joe_bloggs
    and_i_do_not_see_mentor_sarah_doe
  end

  private

  def given_a_school_exists_with_mentors
    @mentor_joe_bloggs = create(
      :placements_mentor,
      first_name: "Joe",
      last_name: "Bloggs",
      trn: 1_111_111,
    )
    @mentor_sarah_doe = create(
      :mentor,
      first_name: "Sarah",
      last_name: "Doe",
      trn: 2_222_222,
    )

    @springfield_elementary_school = create(
      :placements_school,
      name: "Springfield Elementary",
      address1: "Westgate Street",
      address2: "Hackney",
      postcode: "E8 3RL",
      group: "Local authority maintained schools",
      phase: "Primary",
      gender: "Mixed",
      minimum_age: 3,
      maximum_age: 11,
      religious_character: "Does not apply",
      admissions_policy: "Not applicable",
      urban_or_rural: "(England/Wales) Urban major conurbation",
      percentage_free_school_meals: 15,
      rating: "Outstanding",
      mentors: [@mentor_joe_bloggs],
    )
  end

  def and_i_am_signed_in
    sign_in_placements_support_user
  end

  def when_i_am_on_the_organisations_index_page
    expect(page).to have_title("Organisations (2) - Manage school placements - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
  end

  def and_i_select_springfield_elementary
    click_on "Springfield Elementary"
  end

  def and_i_navigate_to_mentors
    within ".app-primary-navigation__nav" do
      click_on "Mentors"
    end
  end

  def then_i_see_the_mentors_at_your_school_page
    expect(page).to have_title("Mentors at your school - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Mentors")
    expect(page).to have_h1("Mentors at your school", class: "govuk-heading-l")
    expect(page).to have_element(
      :p,
      text: "Add mentors to be able to assign them to your placements.",
      class: "govuk-body",
    )
    expect(page).to have_link("Add mentor", class: "govuk-button")
  end

  def and_i_see_mentor_joe_bloggs
    expect(page).to have_table_row({
      "Name" => "Joe Bloggs",
      "Teacher reference number (TRN)" => "1111111",
    })
  end

  def and_i_do_not_see_mentor_sarah_doe
    expect(page).not_to have_table_row({
      "Name" => "Sarah Doe",
    })
  end
end
