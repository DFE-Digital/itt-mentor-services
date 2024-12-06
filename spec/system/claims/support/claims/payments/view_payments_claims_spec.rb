require "rails_helper"

RSpec.describe "View payments claims", :js, service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page without any claims due for payments processing" do
    when_i_visit_claims_payments_index_page
    then_i_see("There are no claims waiting to be processed.")
  end

  scenario "Support user visits the claims index page with claims due for payments processing" do
    information_requested_claim, information_sent_claim = given_there_are_claims_due_for_payments_processing
    when_i_visit_claims_payments_index_page
    then_i_see("2 claims need processing")
    and_i_see_a_list_of_claims([information_requested_claim, information_sent_claim])
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_are_claims_due_for_payments_processing
    [
      create(:claim, :payment_information_requested),
      create(:claim, :payment_information_sent),
    ]
  end

  def when_i_visit_claims_payments_index_page
    click_on("Claims")
    click_on("Payments")
  end

  def then_i_see(message)
    expect(page).to have_content(message)
  end

  def and_i_see_a_list_of_claims(claims)
    claims.each_with_index do |claim, index|
      within(".claim-card:nth-child(#{index + 1})") do
        expect(page).to have_content(claim.reference)
      end
    end
  end
end
