require "rails_helper"

RSpec.describe "View claims", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }
  let(:provider) { create(:claims_provider) }
  let(:mentor) { create(:claims_mentor) }
  let(:user) { create(:claims_user) }
  let!(:claim) do
    create(
      :claim,
      :submitted,
      provider:,
      school: create(:claims_school, region: regions(:inner_london)),
      mentors: [mentor],
      submitted_by: user,
      submitted_at: Time.zone.parse("2024-03-05 12:31:52"),
    )
  end

  let!(:mentor_training) { create(:mentor_training, claim:, mentor:, hours_completed: 6) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visists a submitted claims show page" do
    when_i_visit_claim_index_page
    when_i_click_on_claim(claim)
    then_i_can_see_the_details_of_a_submitted_claim
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def when_i_click_on_claim(claim)
    click_on(claim.school.name)
  end

  def then_i_can_see_the_details_of_a_submitted_claim
    expect(page).to have_content("Claim #{claim.reference}")
    expect(page).to have_content("School#{claim.school.name}")
    expect(page).to have_content("Academic year#{claim.academic_year_name}")
    expect(page).to have_content("Submitted")
    expect(page).to have_content("Submitted by #{user.full_name} on 5 March 2024.")
    expect(page).to have_content("Accredited provider#{provider.name}")
    expect(page).to have_content("Mentors\n#{mentor.full_name}")
    expect(page).to have_content("Hours of training")
    expect(page).to have_content("#{mentor.full_name}#{mentor_training.hours_completed} hours")
    expect(page).to have_content("Total hours6 hours")
    expect(page).to have_content("Hourly rate£53.60")
    expect(page).to have_content("Claim amount£321.60")
  end
end
