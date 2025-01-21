require "rails_helper"

RSpec.describe "Support user filters clawback claims by status", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_clawbacks_index_page
    then_i_see_the_clawbacks_index_page_with_three_claims
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_see_claims_with_a_clawback_requested_status
    and_i_see_claims_with_a_sampling_not_approved_status

    when_i_select_the_clawback_in_progress_filter
    and_i_click_on_apply_filters
    then_i_see_only_one_claim_on_the_clawbacks_index_page
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_do_not_see_claims_with_a_clawback_requested_status
    and_i_do_not_see_claims_with_a_sampling_not_approved_status
    and_i_see_clawback_in_progress_selected_from_the_status_filter
    and_i_do_not_see_clawback_requested_selected_from_the_status_filter
    and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter

    when_i_select_the_clawback_requested_filter
    and_i_click_on_apply_filters
    then_i_see_the_clawbacks_index_page_with_two_claims
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_see_claims_with_a_clawback_requested_status
    and_i_do_not_see_claims_with_a_sampling_not_approved_status
    and_i_see_clawback_in_progress_selected_from_the_status_filter
    and_i_see_clawback_requested_selected_from_the_status_filter
    and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter

    when_i_unselect_the_clawback_in_progress_filter
    and_i_click_on_apply_filters
    then_i_see_only_one_claim_on_the_clawbacks_index_page
    and_i_see_claims_with_a_clawback_requested_status
    and_i_do_not_see_claims_with_a_clawback_in_progress_status
    and_i_do_not_see_claims_with_a_sampling_not_approved_status
    and_i_see_clawback_requested_selected_from_the_status_filter
    and_i_do_not_see_clawback_in_progress_selected_from_the_status_filter
    and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter

    when_i_click_on_the_clawback_requested_filter_tag
    then_i_see_the_clawbacks_index_page_with_three_claims
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_do_not_see_clawback_requested_selected_from_the_status_filter
    and_i_do_not_see_clawback_in_progress_selected_from_the_status_filter
    and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter

    when_i_select_the_clawback_in_progress_filter
    and_i_select_the_clawback_requested_filter
    and_i_select_the_sampling_not_approved_filter
    and_i_click_on_apply_filters
    then_i_see_the_clawbacks_index_page_with_three_claims
    and_i_see_claims_with_a_clawback_requested_status
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_see_claims_with_a_sampling_not_approved_status
    and_i_see_clawback_requested_selected_from_the_status_filter
    and_i_see_clawback_in_progress_selected_from_the_status_filter
    and_i_see_sampling_not_approved_selected_from_the_status_filter

    when_i_click_clear_filters
    then_i_see_the_clawbacks_index_page_with_three_claims
    and_i_see_claims_with_a_clawback_requested_status
    and_i_see_claims_with_a_clawback_in_progress_status
    and_i_see_claims_with_a_sampling_not_approved_status
    and_i_do_not_see_clawback_requested_selected_from_the_status_filter
    and_i_do_not_see_clawback_in_progress_selected_from_the_status_filter
    and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter
  end

  private

  def given_claims_exist
    @clawback_in_progress_claim = create(:claim, :submitted, status: :clawback_in_progress)
    @clawback_requested_claim = create(:claim, :submitted, status: :clawback_requested)
    @sampling_not_approved_claim = create(:claim, :submitted, status: :sampling_not_approved)
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

  def then_i_see_the_clawbacks_index_page_with_three_claims
    i_see_the_clawbacks_index_page
    expect(page).to have_h2("Clawbacks (3)")
  end

  def then_i_see_the_clawbacks_index_page_with_two_claims
    i_see_the_clawbacks_index_page
    expect(page).to have_h2("Clawbacks (2)")
  end

  def then_i_see_only_one_claim_on_the_clawbacks_index_page
    i_see_the_clawbacks_index_page
    expect(page).to have_h2("Clawbacks (1)")
  end

  def i_see_the_clawbacks_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Clawbacks")
    expect(page).to have_current_path(claims_support_claims_clawbacks_path, ignore_query: true)
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
      "status" => "Clawback in progress",
      "academic_year" => @clawback_requested_claim.academic_year.name,
      "provider_name" => @clawback_requested_claim.provider.name,
      "submitted_at" => I18n.l(@clawback_requested_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_claims_with_a_sampling_not_approved_status
    expect(page).to have_claim_card({
      "title" => "#{@sampling_not_approved_claim.reference} - #{@sampling_not_approved_claim.school.name}",
      "url" => "/support/claims/clawbacks/claims/#{@sampling_not_approved_claim.id}",
      "status" => "Sent to payer for clawback",
      "academic_year" => @sampling_not_approved_claim.academic_year.name,
      "provider_name" => @sampling_not_approved_claim.provider.name,
      "submitted_at" => I18n.l(@sampling_not_approved_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def when_i_select_the_clawback_in_progress_filter
    check "Sent to payer for clawback"
  end
  alias_method :and_i_select_the_clawback_in_progress_filter,
               :when_i_select_the_clawback_in_progress_filter

  def when_i_select_the_clawback_requested_filter
    check "Ready for clawback"
  end
  alias_method :and_i_select_the_clawback_requested_filter,
               :when_i_select_the_clawback_requested_filter

  def when_i_unselect_the_clawback_in_progress_filter
    uncheck "Sent to payer for clawback"
  end

  def and_i_select_the_sampling_not_approved_filter
    check "Rejected by school"
  end

  def and_i_do_not_see_claims_with_a_clawback_requested_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@clawback_requested_claim.reference} - #{@clawback_requested_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_sampling_not_approved_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@sampling_not_approved_claim.reference} - #{@sampling_not_approved_claim.school.name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_clawback_in_progress_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@clawback_in_progress_claim.reference} - #{@clawback_in_progress_claim.school.name}" },
    )
  end

  def and_i_see_clawback_in_progress_selected_from_the_status_filter
    expect(page).to have_element(:legend, text: "Status", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Sent to payer for clawback")
    expect(page).to have_filter_tag("Sent to payer for clawback")
  end

  def and_i_see_clawback_requested_selected_from_the_status_filter
    expect(page).to have_element(:legend, text: "Status", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Ready for clawback")
    expect(page).to have_filter_tag("Ready for clawback")
  end

  def and_i_see_sampling_not_approved_selected_from_the_status_filter
    expect(page).to have_element(:legend, text: "Status", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Rejected by school")
    expect(page).to have_filter_tag("Rejected by school")
  end

  def and_i_do_not_see_clawback_requested_selected_from_the_status_filter
    expect(page).not_to have_checked_field("Ready for clawback")
    expect(page).not_to have_filter_tag("Ready for clawback")
  end

  def and_i_do_not_see_sampling_not_approved_selected_from_the_status_filter
    expect(page).not_to have_checked_field("Clawback complete")
    expect(page).not_to have_filter_tag("Clawback complete")
  end

  def and_i_do_not_see_clawback_in_progress_selected_from_the_status_filter
    expect(page).not_to have_checked_field("Sent to payer for clawback")
    expect(page).not_to have_filter_tag("Sent to payer for clawback")
  end

  def when_i_click_on_the_clawback_requested_filter_tag
    within ".app-filter-tags" do
      click_on "Ready for clawback"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
