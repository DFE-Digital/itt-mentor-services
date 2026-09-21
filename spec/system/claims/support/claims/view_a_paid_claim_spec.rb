require "rails_helper"

RSpec.describe "View a paid claim", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }
  let(:mentor) { create(:claims_mentor) }
  let!(:claim) do
    create(
      :claim,
      :paid,
      school: create(:claims_school, region: regions(:inner_london)),
      mentor_trainings: [build(:mentor_training, mentor:)],
      paid_to_la: true,
      date_paid: Date.new(2026, 9, 21),
    )
  end

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user views the payment details of a paid claim" do
    when_i_visit_claim_index_page
    when_i_click_on_claim(claim)
    then_i_can_see_the_payment_details
  end

  context "when the claim was paid to an academy" do
    let!(:claim) do
      create(
        :claim,
        :paid,
        school: create(:claims_school, region: regions(:inner_london)),
        mentor_trainings: [build(:mentor_training, mentor:)],
        paid_to_la: false,
        date_paid: Date.new(2026, 9, 21),
      )
    end

    scenario "Support user sees the claim was paid to the academy" do
      when_i_visit_claim_index_page
      when_i_click_on_claim(claim)
      then_i_can_see_the_claim_was_paid_to_an_academy
    end
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
    click_on(claim.school_name)
  end

  def then_i_can_see_the_payment_details
    expect(page).to have_content("Payment details")
    expect(page).to have_content("Date paid21 September 2026")
    expect(page).to have_content("Paid toLocal authority")
  end

  def then_i_can_see_the_claim_was_paid_to_an_academy
    expect(page).to have_content("Paid toAcademy")
  end
end
