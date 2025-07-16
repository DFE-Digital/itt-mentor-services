require "rails_helper"

RSpec.describe "Support user filters sampled claims by mentor", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222

    when_i_select_john_smith_from_the_mentor_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_do_not_see_the_sampled_claim_with_reference_222222
    and_i_see_john_smith_selected_from_the_mentor_filter
    and_i_do_not_see_sarah_doe_selected_from_the_mentor_filter

    when_i_select_sarah_doe_from_the_mentor_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_john_smith_selected_from_the_mentor_filter
    and_i_see_sarah_doe_selected_from_the_mentor_filter

    when_i_unselect_john_smith_from_the_mentor_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_do_not_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_john_smith_selected_from_the_mentor_filter
    and_i_see_sarah_doe_selected_from_the_mentor_filter

    when_i_click_on_the_sarah_doe_filter_tag
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_john_smith_selected_from_the_mentor_filter
    and_i_do_not_see_sarah_doe_selected_from_the_mentor_filter

    when_i_select_john_smith_from_the_mentor_filter
    and_i_select_sarah_doe_from_the_mentor_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_john_smith_selected_from_the_mentor_filter
    and_i_see_sarah_doe_selected_from_the_mentor_filter

    when_i_click_clear_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_john_smith_selected_from_the_mentor_filter
    and_i_do_not_see_sarah_doe_selected_from_the_mentor_filter
  end

  private

  def given_claims_exist
    @claim_window = build(:claim_window, :current)
    @historic_claim_window = build(:claim_window, :historic)

    @mentor_1 = build(:mentor, first_name: "John", last_name: "Smith", trn: "1111111")
    @mentor_2 = build(:mentor, first_name: "Sarah", last_name: "Doe", trn: "2222222")

    @mentor_1_claim = build(:claim, :audit_requested, claim_window: @claim_window, reference: 111_111)
    @mentor_2_claim = build(:claim, :audit_requested, claim_window: @claim_window, reference: 222_222)

    @mentor_1_training = create(:mentor_training, claim: @mentor_1_claim, mentor: @mentor_1)
    @mentor_2_training = create(:mentor_training, claim: @mentor_2_claim, mentor: @mentor_2)
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

  def and_i_see_2_claims_have_been_found
    expect(page).to have_h2("Auditing (2)")
  end

  def and_i_see_1_claim_has_been_found
    expect(page).to have_h2("Auditing (1)")
  end

  def and_i_see_the_sampled_claim_with_reference_111111
    expect(page).to have_claim_card({
      "title" => "111111 - #{@mentor_1_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@mentor_1_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @mentor_1_claim.academic_year.name,
      "provider_name" => @mentor_1_claim.provider_name,
      "submitted_at" => I18n.l(@mentor_1_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_with_reference_222222
    expect(page).to have_claim_card({
      "title" => "222222 - #{@mentor_2_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@mentor_2_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @mentor_2_claim.academic_year.name,
      "provider_name" => @mentor_2_claim.provider_name,
      "submitted_at" => I18n.l(@mentor_2_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_john_smith_from_the_mentor_filter
    check "John Smith"
  end

  def when_i_select_sarah_doe_from_the_mentor_filter
    check "Sarah Doe"
  end
  alias_method :and_i_select_sarah_doe_from_the_mentor_filter,
               :when_i_select_sarah_doe_from_the_mentor_filter

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_111111
    expect(page).not_to have_claim_card({
      "title" => "111111 - #{@mentor_1_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@mentor_1_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @mentor_1_claim.academic_year.name,
      "provider_name" => @mentor_1_claim.provider_name,
      "submitted_at" => I18n.l(@mentor_1_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_222222
    expect(page).not_to have_claim_card({
      "title" => "222222 - #{@mentor_2_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@mentor_2_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @mentor_2_claim.academic_year.name,
      "provider_name" => @mentor_2_claim.provider_name,
      "submitted_at" => I18n.l(@mentor_2_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_john_smith_selected_from_the_mentor_filter
    expect(page).to have_element(:legend, text: "Mentor", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("John Smith")
    expect(page).to have_filter_tag("John Smith")
  end

  def and_i_see_sarah_doe_selected_from_the_mentor_filter
    expect(page).to have_element(:legend, text: "Mentor", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Sarah Doe")
    expect(page).to have_filter_tag("Sarah Doe")
  end

  def and_i_do_not_see_john_smith_selected_from_the_mentor_filter
    expect(page).not_to have_checked_field("John Smith")
    expect(page).not_to have_filter_tag("John Smith")
  end

  def and_i_do_not_see_sarah_doe_selected_from_the_mentor_filter
    expect(page).not_to have_checked_field("Sarah Doe")
    expect(page).not_to have_filter_tag("Sarah Doe")
  end

  def when_i_unselect_john_smith_from_the_mentor_filter
    uncheck "John Smith"
  end

  def when_i_unselect_sarah_doe_from_the_mentor_filter
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
