require "rails_helper"

RSpec.describe "Support user views amendments on a provider rejected claim", service: :claims, type: :system do
  include MoneyRails::ActionViewExtension

  scenario do
    given_a_provider_rejected_claim_exists
    and_i_am_signed_in

    when_i_view_the_provider_rejected_claim
    then_i_see_the_amended_hours_in_the_provider_response
    and_i_do_not_see_the_unamended_mentor_in_the_provider_response
    and_i_do_not_see_hours_removed
    and_i_see_the_amended_grant_funding
  end

  private

  def given_a_provider_rejected_claim_exists
    @claim = create(:claim,
                    :submitted,
                    status: :sampling_provider_not_approved,
                    amendment_notification_sent_at: 1.day.ago,
                    reference: 11_111_111)
    @amended_mentor = create(:claims_mentor, first_name: "James", last_name: "Chess")
    @unamended_mentor = create(:claims_mentor, first_name: "Sarah", last_name: "Doe")
    @amended_training = create(:mentor_training,
                               claim: @claim,
                               mentor: @amended_mentor,
                               hours_completed: 15,
                               not_assured: true,
                               reason_not_assured: "Incorrect number of hours",
                               hours_clawed_back: 4)
    create(:mentor_training, claim: @claim, mentor: @unamended_mentor, hours_completed: 10)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_view_the_provider_rejected_claim
    visit claims_support_claims_sampling_path(@claim)
  end

  def then_i_see_the_amended_hours_in_the_provider_response
    within(".claim-responses", text: "Provider response") do
      expect(page).to have_element(:h3, text: "Provider response", class: "govuk-heading-s")
      within(".govuk-summary-card") do
        expect(page).to have_element(:div, text: "James Chess", class: "govuk-summary-card__title-wrapper")
        expect(page).to have_summary_list_row("Original hours claimed", "15 hours")
        expect(page).to have_summary_list_row("Amended hours", "11 hours")
        expect(page).to have_summary_list_row("Reason for amendment", "Incorrect number of hours")
      end
    end
  end

  def and_i_do_not_see_the_unamended_mentor_in_the_provider_response
    within(".claim-responses", text: "Provider response") do
      expect(page).not_to have_content("Sarah Doe")
    end
  end

  def and_i_do_not_see_hours_removed
    expect(page).not_to have_content("Hours removed")
  end

  def and_i_see_the_amended_grant_funding
    within("#grant_funding") do
      expect(page).to have_h2("Grant funding")
      expect(page).to have_summary_list_row("Original claim amount", humanized_money_with_symbol(@claim.amount))
      expect(page).to have_summary_list_row("Funding reduction", humanized_money_with_symbol(@claim.total_clawback_amount))
      expect(page).to have_summary_list_row("Amended grant funding total", humanized_money_with_symbol(@claim.amount_after_clawback))
    end
  end
end
