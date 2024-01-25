require "rails_helper"

RSpec.describe "View schools", type: :system do
  around do |example|
    Capybara.app_host = "http://#{ENV["CLAIMS_HOST"]}"
    example.run
    Capybara.app_host = nil
  end

  scenario "I sign in as persona Mary with multiple schools" do
    persona = given_the_claims_persona("Mary")
    and_persona_has_multiple_schools(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    and_i_see_marys_schools
  end

  scenario "I sign in as persona Anne with one school" do
    persona = given_the_claims_persona("Anne")
    and_persona_has_one_school(persona)
    when_i_visit_claims_personas
    when_i_click_sign_in(persona)
    and_i_see_annes_schools
  end

  private

  def given_the_claims_persona(persona_name)
    create(:claims_user, persona_name.downcase.to_sym)
  end

  def and_persona_has_multiple_schools(persona)
    @school1 = create(:claims_school)
    @school2 = create(:claims_school)
    create(:membership, user: persona, organisation: @school1)
    create(:membership, user: persona, organisation: @school2)
  end

  def and_i_see_marys_schools
    expect(page).to have_content "Organisations"
    expect(page).to have_content @school1.name
    expect(page).to have_content @school2.name
  end

  def and_persona_has_one_school(persona)
    create(
      :membership,
      user: persona,
      organisation: create(:school, :claims, name: "Hogwarts"),
    )
  end

  def and_i_see_annes_schools
    expect(page).to have_content "Organisation details"
    expect(page).to have_content "Hogwarts"
  end

  def when_i_visit_claims_personas
    visit personas_path
  end

  def when_i_click_sign_in(persona)
    click_on "Sign In as #{persona.first_name}"
  end

  def i_am_redirected_to_the_root_path
    expect(page).to have_content("Claim Funding for General Mentors")
  end
end
