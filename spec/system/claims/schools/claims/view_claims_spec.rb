require "rails_helper"

RSpec.describe "View claims", service: :claims, type: :system do
  let(:school) { create(:claims_school) }
  let(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  let(:school_with_mentors) do
    create(:claims_school) do |school|
      create_list(:claims_mentor, 2, schools: [school])
    end
  end

  let!(:draft_claim) do
    create(
      :claim,
      :draft,
      school: school_with_mentors,
      provider: build(:claims_provider),
      mentor_trainings: [build(:mentor_training, mentor: school_with_mentors.mentors.first)],
    )
  end
  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school: school_with_mentors,
      provider: create(:claims_provider),
      mentor_trainings: [build(:mentor_training, mentor: school_with_mentors.mentors.first)],
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

  let(:claim_window) { Claims::ClaimWindow.current }

  before do
    create(:claim, status: :internal_draft, school:)
    given_the_school_is_eligible_to_claim
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

  scenario "Anne visits the claims index page with internal draft claims" do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
    visit_claims_index_page
    i_do_not_see_any_internal_draft_claims
  end

  private

  def given_the_school_is_eligible_to_claim
    school.eligible_claim_windows << claim_window
    school_with_mentors.eligible_claim_windows << claim_window
  end

  def i_do_not_see_any_internal_draft_claims
    expect(page).to have_content("There are no claims for #{school.name}")
  end

  def visit_claims_index_page
    click_on "Claims"
  end

  def i_can_see_the_add_a_mentor_guidance
    within(".govuk-inset-text") do
      expect(page).to have_content(
        "Before you can start a claim you will need to add a mentor.",
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
    within(first(".govuk-body")) do
      expect(page).to have_content(
        "You have until 11:59pm on #{I18n.l(claim_window.ends_on, format: :long_with_day)} to submit claims for the academic year September #{claim_window.starts_on.year} to July #{claim_window.ends_on.year}.",
      )
    end
  end

  def i_can_see_the_add_claim_button
    expect(page).to have_link("Add claim")
  end

  def i_see_a_list_of_the_schools_claims
    expect(page).to have_content("Reference")
    expect(page).to have_content("Accredited provider")
    expect(page).to have_content("Mentors")
    expect(page).to have_content("Date submitted")
    expect(page).to have_content("Status")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_content(submitted_claim.reference)
      expect(page).to have_content(submitted_claim.provider_name)
      expect(page).to have_content(submitted_claim.mentors.map(&:full_name).join(""))
      expect(page).to have_content("5 March 2024")
      expect(page).to have_content("Submitted")
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_content(draft_claim.reference)
      expect(page).to have_content(draft_claim.provider_name)
      expect(page).to have_content(draft_claim.mentors.map(&:full_name).join(""))
      expect(page).to have_content("Draft")
    end
  end

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end
end
