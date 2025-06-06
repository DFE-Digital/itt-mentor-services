require "rails_helper"

RSpec.describe "School user views the placements index when not hosting placements",
               service: :placements,
               type: :system do
  scenario do
    given_a_school_exists_with_a_hosting_interest_not_open_to_hosting
    and_i_am_signed_in
    then_i_see_the_school_is_not_hosting_placements
  end

  private

  def given_a_school_exists_with_a_hosting_interest_not_open_to_hosting
    @springfield_elementary_school = build(
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
    )

    @hosting_interest = create(
      :hosting_interest,
      :for_next_year,
      school: @springfield_elementary_school,
      appetite: "not_open",
    )
  end

  def and_i_am_signed_in
    sign_in_placements_user(organisations: [@springfield_elementary_school])
  end

  def then_i_see_the_school_is_not_hosting_placements
    expect(page).to have_title("Placements - Manage school placements - GOV.UK")
    expect(primary_navigation).to have_current_item("Placements")
    expect(page).to have_h1("Placements")
    expect(page).to have_tag("Not offering placements", "red")
    expect(page).to have_paragraph(
      "You are not offering placements this academic year.",
    )
    expect(page).to have_paragraph(
      "Providers will see that you are not offering placements and your contact information will be hidden.",
    )
    expect(page).to have_paragraph(
      "We will email you next year to check whether your placement availability has changed.",
    )
    expect(page).to have_paragraph(
      "If you think you can offer placements, change your status to add placement information.",
    )
    expect(page).to have_link(
      "change your status",
      href: new_edit_hosting_interest_placements_school_hosting_interest_path(
        @springfield_elementary_school,
        @hosting_interest,
      ),
    )
  end
end
