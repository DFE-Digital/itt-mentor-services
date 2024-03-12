require "rails_helper"

RSpec.describe "View a schools claims", type: :system, service: :claims do
  let!(:school) { create(:school, :claims).becomes(Claims::School) }
  let!(:another_school) { create(:school, :claims).becomes(Claims::School) }

  let!(:colin) { create(:claims_support_user, :colin) }

  let!(:submitted_claim) do
    create(
      :claim,
      school_id: school.id,
      draft: false,
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
    )
  end
  let!(:draft_claim) { create(:claim, school_id: school.id, draft: true) }
  let!(:claim_from_another_school) { create(:claim, school_id: another_school.id, draft: true) }

  scenario "View a school's claims as a support user" do
    user_exists_in_dfe_sign_in(user: colin)
    given_i_sign_in
    when_i_visit_the_claims_support_school_claims_page
    i_see_a_list_of_the_schools_claims
    i_dont_see_claims_from_other_schools
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_claims_support_school_claims_page
    visit claims_support_school_claims_path(school)
  end

  def i_see_a_list_of_the_schools_claims
    expect(page).to have_content("Claim reference")
    expect(page).to have_content("Accredited provider")
    expect(page).to have_content("Mentors")
    expect(page).to have_content("Date submitted")
    expect(page).to have_content("Status")
    expect(page).to have_content("Date submitted")

    within("tbody tr:nth-child(1)") do
      expect(page).to have_content(draft_claim.reference)
      expect(page).to have_content(draft_claim.provider_name)
      expect(page).to have_content(draft_claim.mentors.map(&:full_name).join(""))
      expect(page).to have_content("-")
      expect(page).to have_content("Draft")
    end

    within("tbody tr:nth-child(2)") do
      expect(page).to have_content(submitted_claim.reference)
      expect(page).to have_content(submitted_claim.provider_name)
      expect(page).to have_content(submitted_claim.mentors.map(&:full_name).join(""))
      expect(page).to have_content("05/03/2024")
      expect(page).to have_content("Submitted")
    end
  end

  def i_dont_see_claims_from_other_schools
    expect(page).not_to have_content("#{claim_from_another_school.id}\nDraft")
  end
end
