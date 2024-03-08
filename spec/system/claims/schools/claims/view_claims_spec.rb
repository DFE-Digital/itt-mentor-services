require "rails_helper"

RSpec.describe "View claims", type: :system, service: :claims do
  let(:school) { create(:claims_school) }
  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  let(:school_with_mentors) do
    create(
      :claims_school,
      mentors: create_list(:claims_mentor, 2),
    )
  end

  let!(:draft_claim) { create(:claim, :draft, school:) }
  let!(:submitted_claim) do
    create(
      :claim,
      school: school_with_mentors,
      provider: create(:provider),
      mentors: [create(:claims_mentor)],
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
    )
  end
  let(:mary) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school_with_mentors)],
    )
  end

  scenario "Anne visits the claims index page with no mentors" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    i_can_see_the_add_a_mentor_guidance
    i_can_see_the_no_records_message
  end

  scenario "Mary visits the claims index page with mentors" do
    user_exists_in_dfe_sign_in(user: mary)
    given_i_sign_in
    i_can_see_the_claim_guidance
    i_can_see_the_add_claim_button
    i_see_a_list_of_the_schools_claims
  end

  scenario "Anne visits the claims index page with draft claims" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    vist_claims_index_page
    i_do_not_see_any_draft_claims
  end

  private

  def i_do_not_see_any_draft_claims
    expect(page).not_to have_content(draft_claim.id)
    expect(page).to have_content("There are no claims for #{school.name}")
  end

  def vist_claims_index_page
    click_on "Claims"
  end

  def i_can_see_the_add_a_mentor_guidance
    within(".govuk-inset-text") do
      expect(page).to have_content(
        "You need to add a mentor before creating a claim.",
      )
      expect(page).to have_link("add a mentor", href: "/schools/#{school.id}/mentors")
    end
  end

  def i_can_see_the_no_records_message
    expect(page).to have_content(
      "There are no claims for #{school.name}.",
    )
  end

  def i_can_see_the_claim_guidance
    within(".govuk-inset-text") do
      expect(page).to have_content(
        "You can only claim for the academic year September 2023 to July 2024.",
      )
    end
  end

  def i_can_see_the_add_claim_button
    expect(page).to have_link("Add claim")
  end

  def i_see_a_list_of_the_schools_claims
    expect(page).to have_content("Claim reference")
    expect(page).to have_content("Accredited provider")
    expect(page).to have_content("Mentors")
    expect(page).to have_content("Date submitted")
    expect(page).to have_content("Status")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_content(submitted_claim.id.first(8))
      expect(page).to have_content(submitted_claim.provider_name)
      expect(page).to have_content(submitted_claim.mentors.map(&:full_name).join(""))
      expect(page).to have_content("05/03/2024")
      expect(page).to have_content("Submitted")
    end
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
end
