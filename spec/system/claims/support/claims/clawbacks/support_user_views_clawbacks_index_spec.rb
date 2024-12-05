require "rails_helper"

RSpec.describe "Support user views clawbacks index", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_claims_clawbacks_index_page
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_see_claims_with_a_clawback_requested_status
    and_i_see_claims_with_a_sampling_not_approved_status
    and_i_do_not_see_claims_with_a_internal_draft_status
    and_i_do_not_see_claims_with_a_draft_status
    and_i_do_not_see_claims_with_a_submitted_status
    and_i_do_not_see_claims_with_a_payment_in_progress_status
    and_i_do_not_see_claims_with_a_payment_information_requested_status
    and_i_do_not_see_claims_with_a_payment_information_sent_status
    and_i_do_not_see_claims_with_a_paid_status
    and_i_do_not_see_claims_with_a_payment_not_approved_status
    and_i_do_not_see_claims_with_a_clawback_requested_status
    and_i_do_not_see_claims_with_a_clawback_in_progress_status
    and_i_do_not_see_claims_with_a_clawback_complete_status

    when_i_click_to_view_the_clawback_requested_claim
    then_i_see_the_details_of_the_clawback_requested_claim
  end

  private

  def given_claims_exist
    @clawback_in_progress_claim = create(:claim, :submitted, status: :clawback_in_progress)
    @clawback_requested_claim = create(:claim, :submitted, status: :clawback_requested)
    @sampling_not_approved_claim = create(:claim, :submitted, status: :sampling_not_approved)

    @internal_draft_claim = create(:claim)
    @draft_claim = create(:claim, :draft)
    @submitted_claim = create(:claim, :submitted)
    @payment_in_progress_claim = create(:claim, :submitted, status: :payment_in_progress)
    @payment_information_requested_claim = create(:claim, :submitted, status: :payment_information_requested)
    @payment_information_sent_claim = create(:claim, :submitted, status: :payment_information_sent)
    @paid_claim = create(:claim, :submitted, status: :paid)
    @payment_not_approved_claim = create(:claim, :submitted, status: :payment_not_approved)
    @clawback_complete_claim = create(:claim, :submitted, status: :clawback_complete)
    @sampling_in_progress_claim = create(:claim, :submitted, status: :sampling_in_progress)
    @sampling_provider_not_approved_claim = create(:claim, :submitted, status: :sampling_provider_not_approved)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_clawbacks_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Clawbacks"
    end
  end

  def then_i_see_the_claims_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(page).to have_h2("Clawbacks (3)")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
  end

  def and_i_see_claims_with_a_clawback_in_progress_status
    expect(page).to have_claim_card({
      "title" => "#{@clawback_in_progress_claim.reference} - #{@clawback_in_progress_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@clawback_in_progress_claim.id}",
      "status" => "Clawback in progress",
      "academic_year" => @clawback_in_progress_claim.academic_year.name,
      "provider_name" => @clawback_in_progress_claim.provider.name,
      "submitted_at" => I18n.l(@clawback_in_progress_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_claims_with_a_clawback_requested_status
    expect(page).to have_claim_card({
      "title" => "#{@clawback_requested_claim.reference} - #{@clawback_requested_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@clawback_requested_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @clawback_requested_claim.academic_year.name,
      "provider_name" => @clawback_requested_claim.provider.name,
      "submitted_at" => I18n.l(@clawback_requested_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
      "clawback_amount" => "£0.00",
    })
  end

  def and_i_see_claims_with_a_sampling_not_approved_status
    expect(page).to have_claim_card({
      "title" => "#{@sampling_not_approved_claim.reference} - #{@sampling_not_approved_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@sampling_not_approved_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_not_approved_claim.academic_year.name,
      "provider_name" => @sampling_not_approved_claim.provider.name,
      "submitted_at" => I18n.l(@sampling_not_approved_claim.submitted_at.to_date, format: :long),
    })
  end

  def and_i_do_not_see_claims_with_a_internal_draft_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@internal_draft_claim.reference} - #{@internal_draft_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_draft_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@draft_claim.reference} - #{@draft_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_submitted_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@submitted_claim.reference} - #{@submitted_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_payment_in_progress_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@payment_in_progress_claim.reference} - #{@payment_in_progress_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_payment_information_requested_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@payment_information_requested_claim.reference} - #{@payment_information_requested_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_payment_information_sent_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@payment_information_sent_claim.reference} - #{@payment_information_sent_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_paid_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@paid_claim.reference} - #{@paid_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_payment_not_approved_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@payment_not_approved_claim.reference} - #{@payment_not_approved_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_clawback_complete_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@clawback_complete_claim.reference} - #{@clawback_complete_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_clawback_requested_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@clawback_requested_claim.reference} - #{@clawback_requested_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_clawback_in_progress_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@clawback_in_progress_claim.reference} - #{@clawback_in_progress_claim.school.name}" },
    )
  end

  def when_i_click_to_view_the_clawback_requested_claim
    click_on "#{@clawback_requested_claim.reference} - #{@clawback_requested_claim.school.name}"
  end

  def then_i_see_the_details_of_the_clawback_requested_claim
    expect(page).to have_title(
      "Clawbacks - #{@clawback_requested_claim.school.name} - Claim #{@clawback_requested_claim.reference} - Claim funding for mentor training - GOV.UK",
    )
    expect(page).to have_element(:p, text: "Clawbacks - Claim #{@clawback_requested_claim.reference}", class: "govuk-caption-l")
    expect(page).to have_h1(@clawback_requested_claim.school.name)
    expect(page).to have_element(:strong, text: "Clawback requested", class: "govuk-tag govuk-tag--orange")
  end
end
