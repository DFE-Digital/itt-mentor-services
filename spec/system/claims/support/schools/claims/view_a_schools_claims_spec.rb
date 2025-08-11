require "rails_helper"

RSpec.describe "View a schools claims", service: :claims, type: :system do
  let!(:school) { create(:school, :claims).becomes(Claims::School) }
  let!(:another_school) { create(:school, :claims).becomes(Claims::School) }

  let!(:colin) { create(:claims_support_user, :colin) }

  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school_id: school.id,
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
    )
  end
  let!(:draft_claim) { create(:claim, :draft, school_id: school.id) }
  let!(:claim_from_another_school) { create(:claim, :draft, school_id: another_school.id) }

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
    click_on school.name
  end

  def i_see_a_list_of_the_schools_claims
    expect(page).to have_table_row({
      "Reference" => draft_claim.reference,
      "Accredited provider" => draft_claim.provider_name,
      "Mentors" => draft_claim.mentors.map(&:full_name).join(""),
      "Date submitted" => "-",
      "Status" => "Draft",
    })

    expect(page).to have_table_row({
      "Reference" => submitted_claim.reference,
      "Accredited provider" => submitted_claim.provider_name,
      "Mentors" => submitted_claim.mentors.map(&:full_name).join(""),
      "Date submitted" => "5 March 2024",
      "Status" => "Submitted",
    })
  end

  def i_dont_see_claims_from_other_schools
    expect(page).not_to have_content("#{claim_from_another_school.id}\nDraft")
  end
end
