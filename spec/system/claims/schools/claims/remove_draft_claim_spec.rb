require "rails_helper"

RSpec.describe "Create claim", service: :claims, type: :system do
  let!(:school) { create(:claims_school, mentors: [mentor1, mentor2], name: "A School") }
  let!(:anne) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end
  let!(:provider) { create(:provider, :best_practice_network) }

  let(:claims_mentor) { create(:claims_mentor, first_name: "Barry", last_name: "Garlow") }

  let!(:submitted_claim) do
    create(
      :claim,
      :submitted,
      school:,
      reference: "12345678",
      submitted_at: Time.new(2024, 3, 5, 12, 31, 52, "+00:00"),
      provider:,
    )
  end

  let!(:draft_claim) do
    create(
      :claim,
      :draft,
      school:,
      reference: "111111111",
      provider:,
    )
  end

  let(:mentor1) { create(:mentor, first_name: "Anne") }
  let(:mentor2) { create(:mentor, first_name: "Joe") }

  let(:mentor_training) { create(:mentor_training, claim: submitted_claim, mentor: claims_mentor, hours_completed: 6) }
  let(:mentor_training2) { create(:mentor_training, claim: draft_claim, mentor: claims_mentor, hours_completed: 6) }

  before do
    user_exists_in_dfe_sign_in(user: anne)
    given_i_sign_in
  end

  scenario "When removing a draft claim" do
    when_i_visit_the_draft_claim_show_page
    when_i_click_remove_claim
    when_i_confirm_removal
    then_the_claim_has_been_deleted
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_submitted_claim_show_page
    click_on submitted_claim.reference
  end

  def when_i_visit_the_draft_claim_show_page
    click_on draft_claim.reference
  end

  def when_i_click_remove_claim
    click_on "Remove claim"
  end

  def when_i_confirm_removal
    expect(page).to have_content("Are you sure you want to remove this claim?")
    click_on "Remove claim"
  end

  def then_the_claim_has_been_deleted
    expect(page).not_to have_content("111111111")
    expect(page).to have_content("Claim has been removed")
  end
end
