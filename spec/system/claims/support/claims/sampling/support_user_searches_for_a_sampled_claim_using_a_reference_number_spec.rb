require "rails_helper"

RSpec.describe "Support user searches for a sampled claim using a reference number", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_with_reference_11111111
    and_i_see_the_sampled_claim_with_reference_22222222

    when_i_search_for_a_claim_with_reference_11111111
    and_i_click_on_search
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_with_reference_11111111
    and_i_do_not_see_the_sampled_claim_with_reference_22222222
    and_i_see_11111111_entered_into_the_search_by_claim_reference_filter

    when_i_select_hogwarts_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_with_reference_11111111
    and_i_do_not_see_the_sampled_claim_with_reference_22222222
    and_i_see_11111111_entered_into_the_search_by_claim_reference_filter
    and_i_see_hogwarts_selected_from_the_school_filter

    when_i_clear_the_search_for_a_claim_with_reference_11111111
    and_i_click_on_search
    and_i_see_the_sampled_claim_with_reference_11111111
    and_i_see_the_sampled_claim_with_reference_22222222
    and_i_see_hogwarts_selected_from_the_school_filter
  end

  private

  def given_claims_exist
    @hogwarts_school = create(:claims_school, name: "Hogwarts")
    @claim_11111111 = create(:claim,
                             :submitted,
                             status: :sampling_in_progress,
                             school: @hogwarts_school,
                             reference: 11_111_111)
    @claim_22222222 = create(:claim,
                             :submitted,
                             status: :sampling_in_progress,
                             school: @hogwarts_school,
                             reference: 22_222_222)
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

  def and_i_see_the_sampled_claim_with_reference_11111111
    expect(page).to have_claim_card({
      "title" => "#{@claim_11111111.reference} - #{@claim_11111111.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_11111111.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_11111111.academic_year.name,
      "provider_name" => @claim_11111111.provider.name,
      "submitted_at" => I18n.l(@claim_11111111.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_with_reference_22222222
    expect(page).to have_claim_card({
      "title" => "#{@claim_22222222.reference} - #{@claim_22222222.school.name}",
      "url" => "/support/claims/sampling/claims/#{@claim_22222222.id}",
      "status" => "Sampling in progress",
      "academic_year" => @claim_22222222.academic_year.name,
      "provider_name" => @claim_22222222.provider.name,
      "submitted_at" => I18n.l(@claim_22222222.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_search_for_a_claim_with_reference_11111111
    fill_in "Search by claim reference", with: 11_111_111
  end

  def and_i_click_on_search
    click_on "Search"
  end

  def and_i_do_not_see_the_sampled_claim_with_reference_22222222
    expect(page).not_to have_claim_card({
      "title" => "#{@claim_22222222.reference} - #{@claim_22222222.school.name}",
    })
  end

  def and_i_see_11111111_entered_into_the_search_by_claim_reference_filter
    expect(page).to have_field("Search by claim reference", with: 11_111_111)
  end

  def when_i_select_hogwarts_from_the_school_filter
    check "Hogwarts"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_see_hogwarts_selected_from_the_school_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Hogwarts")
    expect(page).to have_filter_tag("Hogwarts")
  end

  def when_i_clear_the_search_for_a_claim_with_reference_11111111
    fill_in "Search by claim reference", with: ""
  end
end
