require "rails_helper"

RSpec.describe "Support user filters sampled claims by status", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_see_claims_with_a_sampling_provider_not_approved_status

    when_i_select_the_sampling_in_progress_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_do_not_see_claims_with_a_sampling_provider_not_approved_status
    and_i_see_sampling_in_progress_selected_from_the_status_filter
    and_i_do_not_see_sampling_provider_not_approved_selected_from_the_status_filter

    when_i_select_the_sampling_provider_not_approved_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_see_claims_with_a_sampling_provider_not_approved_status
    and_i_see_sampling_in_progress_selected_from_the_status_filter
    and_i_see_sampling_provider_not_approved_selected_from_the_status_filter

    when_i_unselect_the_sampling_in_progress_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_claims_with_a_sampling_provider_not_approved_status
    and_i_do_not_see_claims_with_a_sampling_in_progress_status
    and_i_see_sampling_provider_not_approved_selected_from_the_status_filter
    and_i_do_not_see_sampling_in_progress_selected_from_the_status_filter

    when_i_click_on_the_sampling_provider_not_approved_filter_tag
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_claims_with_a_sampling_provider_not_approved_status
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_do_not_see_sampling_provider_not_approved_selected_from_the_status_filter
    and_i_do_not_see_sampling_in_progress_selected_from_the_status_filter

    when_i_select_the_sampling_in_progress_filter
    and_i_select_the_sampling_provider_not_approved_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_claims_with_a_sampling_provider_not_approved_status
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_see_sampling_provider_not_approved_selected_from_the_status_filter
    and_i_see_sampling_in_progress_selected_from_the_status_filter

    when_i_click_clear_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_claims_with_a_sampling_provider_not_approved_status
    and_i_see_claims_with_a_sampling_in_progress_status
    and_i_do_not_see_sampling_provider_not_approved_selected_from_the_status_filter
    and_i_do_not_see_sampling_in_progress_selected_from_the_status_filter
  end

  private

  def given_claims_exist
    @sampling_in_progress_claim = create(:claim, :submitted, status: :sampling_in_progress)
    @sampling_provider_not_approved_claim = create(:claim, :submitted, status: :sampling_provider_not_approved)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Auditing"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Auditing (2)")
  end
  alias_method :then_i_see_all_claims_on_the_claims_sampling_index_page,
               :then_i_see_the_sampling_claims_index_page

  def then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Auditing (1)")
  end

  def i_see_the_sampling_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Auditing")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def and_i_see_claims_with_a_sampling_in_progress_status
    expect(page).to have_claim_card({
      "title" => "#{@sampling_in_progress_claim.reference} - #{@sampling_in_progress_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_in_progress_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_in_progress_claim.academic_year.name,
      "provider_name" => @sampling_in_progress_claim.provider_name,
      "submitted_at" => I18n.l(@sampling_in_progress_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_claims_with_a_sampling_provider_not_approved_status
    expect(page).to have_claim_card({
      "title" => "#{@sampling_provider_not_approved_claim.reference} - #{@sampling_provider_not_approved_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@sampling_provider_not_approved_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @sampling_provider_not_approved_claim.academic_year.name,
      "provider_name" => @sampling_provider_not_approved_claim.provider_name,
      "submitted_at" => I18n.l(@sampling_provider_not_approved_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def when_i_select_the_sampling_in_progress_filter
    check "Audit requested"
  end
  alias_method :and_i_select_the_sampling_in_progress_filter,
               :when_i_select_the_sampling_in_progress_filter

  def when_i_select_the_sampling_provider_not_approved_filter
    check "Rejected by provider"
  end
  alias_method :and_i_select_the_sampling_provider_not_approved_filter,
               :when_i_select_the_sampling_provider_not_approved_filter

  def when_i_unselect_the_sampling_in_progress_filter
    uncheck "Audit requested"
  end

  def and_i_do_not_see_claims_with_a_sampling_provider_not_approved_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@sampling_provider_not_approved_claim.reference} - #{@sampling_provider_not_approved_claim.school_name}" },
    )
  end

  def and_i_do_not_see_claims_with_a_sampling_in_progress_status
    expect(page).not_to have_claim_card(
      { "title" => "#{@sampling_in_progress_claim.reference} - #{@sampling_in_progress_claim.school_name}" },
    )
  end

  def and_i_see_sampling_in_progress_selected_from_the_status_filter
    expect(page).to have_element(:legend, text: "Status", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Audit requested")
    expect(page).to have_filter_tag("Audit requested")
  end

  def and_i_see_sampling_provider_not_approved_selected_from_the_status_filter
    expect(page).to have_element(:legend, text: "Status", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Rejected by provider")
    expect(page).to have_filter_tag("Rejected by provider")
  end

  def and_i_do_not_see_sampling_provider_not_approved_selected_from_the_status_filter
    expect(page).not_to have_checked_field("Rejected by provider")
    expect(page).not_to have_filter_tag("Rejected by provider")
  end

  def and_i_do_not_see_sampling_in_progress_selected_from_the_status_filter
    expect(page).not_to have_checked_field("Audit requested")
    expect(page).not_to have_filter_tag("Audit requested")
  end

  def when_i_click_on_the_sampling_provider_not_approved_filter_tag
    within ".app-filter-tags" do
      click_on "Rejected by provider"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
