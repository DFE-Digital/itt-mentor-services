require "rails_helper"

RSpec.describe "View payments claims", service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page without any claims due for payments processing" do
    when_i_visit_claims_payments_index_page
    then_i_see("There are no claims waiting to be processed.")
  end

  scenario "Support user visits the claims index page when there are submitted claims" do
    given_there_are_submitted_claims
    when_i_visit_claims_payments_index_page
    then_i_see_claims_are_waiting_to_be_sent_to_payer
  end

  scenario "Support user visits the claims index page when there are claims waiting for a payer response" do
    given_there_are_payment_in_progress_claims
    when_i_visit_claims_payments_index_page
    then_i_see_claims_are_awaiting_a_response_from_payer
  end

  scenario "Support user visits the claims index page with claims due for payments processing" do
    given_there_are_claims_due_for_payments_processing
    when_i_visit_claims_payments_index_page
    then_i_see_claims_require_more_information
    and_i_see_an_information_requested_claim
    and_i_see_an_information_sent_claim
  end

  scenario "Support user visits the claims index page with claims in all stages of the payments process" do
    given_there_are_claims_due_for_payments_processing
    and_there_are_submitted_claims
    and_there_are_payment_in_progress_claims
    when_i_visit_claims_payments_index_page
    then_i_see_claims_are_waiting_to_be_sent_to_payer
    and_i_see_claims_are_waiting_to_be_sent_to_payer
    and_i_see_claims_require_more_information
    and_i_see_an_information_requested_claim
    and_i_see_an_information_sent_claim
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_are_claims_due_for_payments_processing
    @information_requested_claim = create(:claim, :payment_information_requested)
    @information_sent_claim = create(:claim, :payment_information_sent)
  end

  def when_i_visit_claims_payments_index_page
    click_on("Claims")
    click_on("Payments")
  end

  def then_i_see(message)
    expect(page).to have_content(message)
  end

  def and_i_see_an_information_requested_claim
    expect(page).to have_claim_card({
      "title" => "#{@information_requested_claim.reference} - #{@information_requested_claim.school.name}",
      "url" => "/support/claims/payments/claims/#{@information_requested_claim.id}",
      "status" => "Payer needs information",
      "academic_year" => @information_requested_claim.academic_year.name,
      "provider_name" => @information_requested_claim.provider_name,
      "submitted_at" => I18n.l(@information_requested_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_an_information_sent_claim
    expect(page).to have_claim_card({
      "title" => "#{@information_sent_claim.reference} - #{@information_sent_claim.school.name}",
      "url" => "/support/claims/payments/claims/#{@information_sent_claim.id}",
      "status" => "Information sent to payer",
      "academic_year" => @information_sent_claim.academic_year.name,
      "provider_name" => @information_sent_claim.provider_name,
      "submitted_at" => I18n.l(@information_sent_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def given_there_are_submitted_claims
    create_list(:claim, 3, :submitted)
  end
  alias_method :and_there_are_submitted_claims, :given_there_are_submitted_claims

  def given_there_are_payment_in_progress_claims
    create_list(:claim, 5, :payment_in_progress)
  end
  alias_method :and_there_are_payment_in_progress_claims,
               :given_there_are_payment_in_progress_claims

  def then_i_see_claims_are_awaiting_a_response_from_payer
    within("#action_calculator") do
      expect(page).to have_element(
        :p,
        text: "5 claims awaiting a response from payer",
        class: "govuk-body",
      )
    end
  end

  def then_i_see_claims_are_waiting_to_be_sent_to_payer
    within("#action_calculator") do
      expect(page).to have_element(
        :p,
        text: "3 claims waiting to be sent to payer",
        class: "govuk-body",
      )
    end
  end
  alias_method :and_i_see_claims_are_waiting_to_be_sent_to_payer,
               :then_i_see_claims_are_waiting_to_be_sent_to_payer

  def then_i_see_claims_require_more_information
    within("#action_calculator") do
      expect(page).to have_element(
        :p,
        text: "10 claims require more information",
        class: "govuk-body",
      )
    end
  end
  alias_method :and_i_see_claims_require_more_information,
               :then_i_see_claims_require_more_information
end
