require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let!(:school) { create(:school, :claims).becomes(Claims::School) }
  let!(:mentor_trainings) do
    [
      create(:mentor_training, claim: create(:claim, school:)),
      create(:mentor_training, claim: create(:claim, school:)),
    ]
  end
  let!(:anne) do
    create(
      :persona,
      :anne,
      service: "claims",
      memberships: [create(:membership, organisation: school)],
    )
  end

  before do
    given_i_sign_in_as_anne
  end

  scenario "Anne visits the claims index page" do
    when_i_visit_claim_index_page
    i_see_a_list_of_the_schools_claims
  end

  private

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def i_see_a_list_of_the_schools_claims
    school.claims.each_with_index do |_, index|
      expect(page).to have_content("Claim #{index + 1}")
    end
  end

  def given_i_sign_in_as_anne
    and_i_visit_the_personas_page
    and_i_click_sign_in_as("Anne")
  end

  def and_i_visit_the_personas_page
    visit personas_path
  end

  def and_i_click_sign_in_as(persona_name)
    click_on "Sign In as #{persona_name}"
  end
end
