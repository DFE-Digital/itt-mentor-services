require "rails_helper"

RSpec.describe "Support user filters sampled claims by training type", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222

    when_i_select_initial_from_the_training_type_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_do_not_see_the_sampled_claim_with_reference_222222
    and_i_see_initial_selected_from_the_training_type_filter
    and_i_do_not_see_refresher_selected_from_the_training_type_filter

    when_i_select_refresher_from_the_training_type_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_initial_selected_from_the_training_type_filter
    and_i_see_refresher_selected_from_the_training_type_filter

    when_i_unselect_initial_from_the_training_type_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_1_claim_has_been_found
    and_i_do_not_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_initial_selected_from_the_training_type_filter
    and_i_see_refresher_selected_from_the_training_type_filter

    when_i_click_on_the_refresher_filter_tag
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_initial_selected_from_the_training_type_filter
    and_i_do_not_see_refresher_selected_from_the_training_type_filter

    when_i_select_initial_from_the_training_type_filter
    and_i_select_refresher_from_the_training_type_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_see_initial_selected_from_the_training_type_filter
    and_i_see_refresher_selected_from_the_training_type_filter

    when_i_click_clear_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_2_claims_have_been_found
    and_i_see_the_sampled_claim_with_reference_111111
    and_i_see_the_sampled_claim_with_reference_222222
    and_i_do_not_see_initial_selected_from_the_training_type_filter
    and_i_do_not_see_refresher_selected_from_the_training_type_filter
  end

  private

  def given_claims_exist
    @claim_window = build(:claim_window, :current)
    @historic_claim_window = build(:claim_window, :historic)

    @claim_1 = build(:claim, :audit_requested, reference: 111_111)
    @claim_2 = build(:claim, :audit_requested, reference: 222_222)

    @initial_mentor_training = create(:mentor_training, claim: @claim_1, training_type: :initial)
    @refresher_mentor_training = create(:mentor_training, claim: @claim_2, training_type: :refresher)
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
      "title" => "111111 - #{@claim_1.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_1.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_1.academic_year.name,
      "provider_name" => @claim_1.provider_name,
      "submitted_at" => I18n.l(@claim_1.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_with_reference_222222
    expect(page).to have_claim_card({
      "title" => "222222 - #{@claim_2.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_2.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_2.academic_year.name,
      "provider_name" => @claim_2.provider_name,
      "submitted_at" => I18n.l(@claim_2.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_initial_from_the_training_type_filter
    check "Initial"
  end

  def when_i_select_refresher_from_the_training_type_filter
    check "Refresher"
  end
  alias_method :and_i_select_refresher_from_the_training_type_filter,
               :when_i_select_refresher_from_the_training_type_filter

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_111111
    expect(page).not_to have_claim_card({
      "title" => "111111 - #{@claim_1.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_1.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_1.academic_year.name,
      "provider_name" => @claim_1.provider_name,
      "submitted_at" => I18n.l(@claim_1.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_222222
    expect(page).not_to have_claim_card({
      "title" => "222222 - #{@claim_2.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_2.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_2.academic_year.name,
      "provider_name" => @claim_2.provider_name,
      "submitted_at" => I18n.l(@claim_2.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_initial_selected_from_the_training_type_filter
    expect(page).to have_element(:legend, text: "Training type", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Initial")
    expect(page).to have_filter_tag("Initial")
  end

  def and_i_see_refresher_selected_from_the_training_type_filter
    expect(page).to have_element(:legend, text: "Training type", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Refresher")
    expect(page).to have_filter_tag("Refresher")
  end

  def and_i_do_not_see_initial_selected_from_the_training_type_filter
    expect(page).not_to have_checked_field("Initial")
    expect(page).not_to have_filter_tag("Initial")
  end

  def and_i_do_not_see_refresher_selected_from_the_training_type_filter
    expect(page).not_to have_checked_field("Refresher")
    expect(page).not_to have_filter_tag("Refresher")
  end

  def when_i_unselect_initial_from_the_training_type_filter
    uncheck "Initial"
  end

  def when_i_unselect_refresher_from_the_training_type_filter
    uncheck "Refresher"
  end

  def when_i_click_on_the_refresher_filter_tag
    within ".app-filter-tags" do
      click_on "Refresher"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
