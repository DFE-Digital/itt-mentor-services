require "rails_helper"

RSpec.describe "Support user filters sampled claims submitted before a date", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_submitted_in_may
    and_i_see_the_sampled_claim_submitted_in_july

    when_i_enter_1st_june_into_the_submitted_before_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_submitted_in_may
    and_i_do_not_see_the_sampled_claim_submitted_in_july
    and_i_see_1st_june_entered_into_the_submitted_before_filter

    when_i_click_on_the_1st_june_filter_tag
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_submitted_in_may
    and_i_see_the_sampled_claim_submitted_in_july
    and_i_do_not_see_1st_june_entered_into_the_submitted_before_filter

    when_i_enter_1st_june_into_the_submitted_before_filter
    and_i_click_on_apply_filters
    then_i_see_only_filtered_claims_on_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_submitted_in_may
    and_i_do_not_see_the_sampled_claim_submitted_in_july
    and_i_see_1st_june_entered_into_the_submitted_before_filter

    when_i_click_clear_filters
    then_i_see_all_claims_on_the_claims_sampling_index_page
    and_i_see_the_sampled_claim_submitted_in_may
    and_i_see_the_sampled_claim_submitted_in_july
    and_i_do_not_see_1st_june_entered_into_the_submitted_before_filter
  end

  private

  def given_claims_exist
    @may_claim = create(:claim,
                        :submitted,
                        status: :sampling_in_progress,
                        submitted_at: Time.current.change(month: 5))
    @july_claim = create(:claim,
                         :submitted,
                         status: :sampling_provider_not_approved,
                         submitted_at: Time.current.change(month: 7))
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

  def and_i_see_the_sampled_claim_submitted_in_may
    expect(page).to have_claim_card({
      "title" => "#{@may_claim.reference} - #{@may_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@may_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @may_claim.academic_year.name,
      "provider_name" => @may_claim.provider_name,
      "submitted_at" => I18n.l(@may_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_submitted_in_july
    expect(page).to have_claim_card({
      "title" => "#{@july_claim.reference} - #{@july_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@july_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @july_claim.academic_year.name,
      "provider_name" => @july_claim.provider_name,
      "submitted_at" => I18n.l(@july_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def when_i_enter_1st_june_into_the_submitted_before_filter
    within_fieldset("Submitted before") do
      fill_in("Day", with: 1)
      fill_in("Month", with: 6)
      fill_in("Year", with: Time.current.year)
    end
  end

  def and_i_do_not_see_the_sampled_claim_submitted_in_july
    expect(page).not_to have_claim_card({
      "title" => "#{@july_claim.reference} - #{@july_claim.school_name}",
    })
  end

  def and_i_see_1st_june_entered_into_the_submitted_before_filter
    expect(page).to have_element(:legend, text: "Submitted before", class: "govuk-fieldset__legend")
    expect(page).to have_filter_tag("01/06/#{Time.current.year}")
    within_fieldset("Submitted before") do
      expect(page).to have_field("Day", with: 1)
      expect(page).to have_field("Month", with: 6)
      expect(page).to have_field("Year", with: Time.current.year)
    end
  end

  def and_i_do_not_see_1st_june_entered_into_the_submitted_before_filter
    expect(page).not_to have_filter_tag("01/06/#{Time.current.year}")
  end

  def when_i_click_on_the_1st_june_filter_tag
    within ".app-filter-tags" do
      click_on "01/06/#{Time.current.year}"
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
