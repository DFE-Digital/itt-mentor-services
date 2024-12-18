require "rails_helper"

RSpec.describe "Support user filters sampled claims by school", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_see_the_sampled_claim_for_hogwarts

    when_i_select_springfield_elementary_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_do_not_see_sampled_claim_for_hogwarts
    and_i_see_springfield_elementary_selected_from_the_school_filter
    and_i_do_not_see_hogwarts_selected_from_the_school_filter

    when_i_select_hogwarts_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_see_the_sampled_claim_for_hogwarts
    and_i_see_springfield_elementary_selected_from_the_school_filter
    and_i_see_hogwarts_selected_from_the_school_filter

    when_i_unselect_springfield_elementary_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_hogwarts
    and_i_do_not_see_sampled_claim_for_springfield_elementary
    and_i_see_hogwarts_selected_from_the_school_filter
    and_i_do_not_see_springfield_elementary_selected_from_the_school_filter

    when_i_click_on_the_hogwarts_filter_tag
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_for_hogwarts
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_do_not_see_hogwarts_selected_from_the_school_filter
    and_i_do_not_see_springfield_elementary_selected_from_the_school_filter

    when_i_select_hogwarts_from_the_school_filter
    and_i_select_springfield_elementary_from_the_school_filter
    and_i_click_on_apply_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_see_the_sampled_claim_for_hogwarts
    and_i_see_springfield_elementary_selected_from_the_school_filter
    and_i_see_hogwarts_selected_from_the_school_filter

    when_i_click_clear_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_for_springfield_elementary
    and_i_see_the_sampled_claim_for_hogwarts
    and_i_do_not_see_springfield_elementary_selected_from_the_school_filter
    and_i_do_not_see_hogwarts_selected_from_the_school_filter
  end

  private

  def given_claims_exist
    @springfield_school = create(:claims_school, name: "Springfield Elementary")
    @springfield_claim = create(:claim,
                                :submitted,
                                status: :sampling_in_progress,
                                school: @springfield_school)

    @hogwarts_school = create(:claims_school, name: "Hogwarts")
    @hogwarts_claim = create(:claim,
                             :submitted,
                             status: :sampling_in_progress,
                             school: @hogwarts_school)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def when_i_navigate_to_the_sampling_claims_index_page
    within primary_navigation do
      click_on "Claims"
    end

    within secondary_navigation do
      click_on "Sampling"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Sampling (2)")
  end
  alias_method :then_i_see_all_claims_on_the_claims_sampling_index_page,
               :then_i_see_the_sampling_claims_index_page

  def then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    i_see_the_sampling_index_page
    expect(page).to have_h2("Sampling (1)")
  end

  def i_see_the_sampling_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Sampling")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def and_i_see_the_sampled_claim_for_springfield_elementary
    expect(page).to have_claim_card({
      "title" => "#{@springfield_claim.reference} - #{@springfield_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@springfield_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @springfield_claim.academic_year.name,
      "provider_name" => @springfield_claim.provider.name,
      "submitted_at" => I18n.l(@springfield_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_for_hogwarts
    expect(page).to have_claim_card({
      "title" => "#{@hogwarts_claim.reference} - #{@hogwarts_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@hogwarts_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @hogwarts_claim.academic_year.name,
      "provider_name" => @hogwarts_claim.provider.name,
      "submitted_at" => I18n.l(@hogwarts_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_springfield_elementary_from_the_school_filter
    check "Springfield Elementary"
  end
  alias_method :and_i_select_springfield_elementary_from_the_school_filter,
               :when_i_select_springfield_elementary_from_the_school_filter

  def when_i_select_hogwarts_from_the_school_filter
    check "Hogwarts"
  end
  alias_method :and_i_select_hogwarts_from_the_school_filter,
               :when_i_select_hogwarts_from_the_school_filter

  def when_i_unselect_springfield_elementary_from_the_school_filter
    uncheck "Springfield Elementary"
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_sampled_claim_for_hogwarts
    expect(page).not_to have_claim_card(
      { "title" => "#{@hogwarts_claim.reference} - #{@hogwarts_claim.school_name}" },
    )
  end

  def and_i_do_not_see_sampled_claim_for_springfield_elementary
    expect(page).not_to have_claim_card(
      { "title" => "#{@springfield_claim.reference} - #{@springfield_claim.school_name}" },
    )
  end

  def and_i_see_springfield_elementary_selected_from_the_school_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Springfield Elementary")
    expect(page).to have_filter_tag("Springfield Elementary")
  end

  def and_i_see_hogwarts_selected_from_the_school_filter
    expect(page).to have_element(:legend, text: "School", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field("Hogwarts")
    expect(page).to have_filter_tag("Hogwarts")
  end

  def and_i_do_not_see_hogwarts_selected_from_the_school_filter
    expect(page).not_to have_checked_field("Hogwarts")
    expect(page).not_to have_filter_tag("Hogwarts")
  end

  def and_i_do_not_see_springfield_elementary_selected_from_the_school_filter
    expect(page).not_to have_checked_field("Springfield Elementary")
    expect(page).not_to have_filter_tag("Springfield Elementary")
  end

  def when_i_click_on_the_hogwarts_filter_tag
    within ".app-filter-tags" do
      click_on "Hogwarts"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
