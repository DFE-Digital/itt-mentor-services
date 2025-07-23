require "rails_helper"

RSpec.describe "Support user filters sampled claims by support user", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_3_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_the_sampled_claim_with_reference_333333

    when_i_select_john_smith_from_the_support_user_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_do_not_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_the_sampled_claim_with_reference_333333
    and_i_see_john_smith_selected_from_the_support_user_filter
    and_i_do_not_see_sarah_doe_selected_from_the_support_user_filter
    and_i_do_not_see_unassigned_selected_from_the_support_user_filter

    when_i_select_sarah_doe_from_the_support_user_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_the_sampled_claim_with_reference_333333
    and_i_see_john_smith_selected_from_the_support_user_filter
    and_i_see_sarah_doe_selected_from_the_support_user_filter
    and_i_do_not_see_unassigned_selected_from_the_support_user_filter

    when_i_unselect_john_smith_from_the_support_user_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_do_not_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_the_sampled_claim_with_reference_333333
    and_i_do_not_see_john_smith_selected_from_the_support_user_filter
    and_i_see_sarah_doe_selected_from_the_support_user_filter
    and_i_do_not_see_unassigned_selected_from_the_support_user_filter

    when_i_click_on_the_sarah_doe_filter_tag
    then_i_see_the_sampling_claims_index_page
    and_i_see_3_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_the_sampled_claim_with_reference_333333
    and_i_do_not_see_john_smith_selected_from_the_support_user_filter
    and_i_do_not_see_sarah_doe_selected_from_the_support_user_filter
    and_i_do_not_see_unassigned_selected_from_the_support_user_filter

    when_i_select_unassigned_from_the_support_user_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_do_not_see_the_sampled_claim_with_reference_111111
    and_i_do_not_see_the_sampled_claim_with_reference_222222
    and_i_see_the_sampled_claim_with_reference_333333
    and_i_see_unassigned_selected_from_the_support_user_filter
    and_i_do_not_see_john_smith_selected_from_the_support_user_filter
    and_i_do_not_see_sarah_doe_selected_from_the_support_user_filter

    when_i_click_clear_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_3_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_the_sampled_claim_with_reference_333333
    and_i_do_not_see_john_smith_selected_from_the_support_user_filter
    and_i_do_not_see_sarah_doe_selected_from_the_support_user_filter
    and_i_do_not_see_unassigned_selected_from_the_support_user_filter
  end

  private

  def given_claims_exist
    @claim_window = build(:claim_window, :current)
    @historic_claim_window = build(:claim_window, :historic)

    @support_user_1 = build(:claims_support_user, first_name: "John", last_name: "Smith")
    @support_user_2 = build(:claims_support_user, first_name: "Sarah", last_name: "Doe")

    @support_user_1_claim = create(:claim, :audit_requested, support_user: @support_user_1, reference: 111_111)
    @support_user_2_claim = create(:claim, :audit_requested, support_user: @support_user_2, reference: 222_222)
    @support_user_3_claim = create(:claim, :audit_requested, reference: 333_333)
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
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Auditing")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def and_i_see_3_claims_have_been_found
    expect(page).to have_h2("Auditing (3)")
  end

  def and_i_see_2_claims_have_been_found
    expect(page).to have_h2("Auditing (2)")
  end

  def and_i_see_1_claim_has_been_found
    expect(page).to have_h2("Auditing (1)")
  end

  def and_i_see_the_sampled_claim_with_reference_111111
    expect(page).to have_claim_card({
      "title" => "111111 - #{@support_user_1_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_1_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_1_claim.academic_year.name,
      "provider_name" => @support_user_1_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_1_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_with_reference_222222
    expect(page).to have_claim_card({
      "title" => "222222 - #{@support_user_2_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_2_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_2_claim.academic_year.name,
      "provider_name" => @support_user_2_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_2_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_with_reference_333333
    expect(page).to have_claim_card({
      "title" => "333333 - #{@support_user_3_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_3_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_3_claim.academic_year.name,
      "provider_name" => @support_user_3_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_3_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_john_smith_from_the_support_user_filter
    check "John Smith"
  end

  def when_i_select_sarah_doe_from_the_support_user_filter
    check "Sarah Doe"
  end
  alias_method :and_i_select_sarah_doe_from_the_support_user_filter,
               :when_i_select_sarah_doe_from_the_support_user_filter

  def when_i_select_unassigned_from_the_support_user_filter
    check "Unassigned"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_111111
    expect(page).not_to have_claim_card({
      "title" => "111111 - #{@support_user_1_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_1_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_1_claim.academic_year.name,
      "provider_name" => @support_user_1_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_1_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_222222
    expect(page).not_to have_claim_card({
      "title" => "222222 - #{@support_user_2_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_2_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_2_claim.academic_year.name,
      "provider_name" => @support_user_2_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_2_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_333333
    expect(page).not_to have_claim_card({
      "title" => "333333 - #{@support_user_3_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@support_user_3_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @support_user_3_claim.academic_year.name,
      "provider_name" => @support_user_3_claim.provider_name,
      "submitted_at" => I18n.l(@support_user_3_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_john_smith_selected_from_the_support_user_filter
    expect(page).to have_element(:legend, text: "Support user", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("John Smith")
    expect(page).to have_filter_tag("John Smith")
  end

  def and_i_see_sarah_doe_selected_from_the_support_user_filter
    expect(page).to have_element(:legend, text: "Support user", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Sarah Doe")
    expect(page).to have_filter_tag("Sarah Doe")
  end

  def and_i_see_unassigned_selected_from_the_support_user_filter
    expect(page).to have_element(:legend, text: "Support user", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Unassigned")
    expect(page).to have_filter_tag("Unassigned")
  end

  def and_i_do_not_see_john_smith_selected_from_the_support_user_filter
    expect(page).not_to have_checked_field("John Smith")
    expect(page).not_to have_filter_tag("John Smith")
  end

  def and_i_do_not_see_sarah_doe_selected_from_the_support_user_filter
    expect(page).not_to have_checked_field("Sarah Doe")
    expect(page).not_to have_filter_tag("Sarah Doe")
  end

  def and_i_do_not_see_unassigned_selected_from_the_support_user_filter
    expect(page).not_to have_checked_field("Unassigned")
    expect(page).not_to have_filter_tag("Unassigned")
  end

  def when_i_unselect_john_smith_from_the_support_user_filter
    uncheck "John Smith"
  end

  def when_i_unselect_sarah_doe_from_the_support_user_filter
    uncheck "Sarah Doe"
  end

  def when_i_click_on_the_sarah_doe_filter_tag
    within ".app-filter-tags" do
      click_on "Sarah Doe"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
