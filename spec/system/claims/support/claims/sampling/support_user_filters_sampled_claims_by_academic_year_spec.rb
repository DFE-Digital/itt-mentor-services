require "rails_helper"

RSpec.describe "Support user filters sampled claims by academic year", service: :claims, type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_the_current_academic_year
    and_i_do_not_see_the_sampled_claim_for_the_previous_academic_year

    when_i_select_the_previous_year_from_the_academic_year_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_the_previous_academic_year
    and_i_do_not_see_the_sampled_claim_for_the_current_academic_year

    when_i_select_the_current_year_from_the_academic_year_filter
    and_i_click_on_apply_filters
    then_i_see_the_sampling_claims_index_page
    and_i_see_the_sampled_claim_for_the_current_academic_year
    and_i_do_not_see_the_sampled_claim_for_the_previous_academic_year
  end

  private

  def given_claims_exist
    @current_academic_year = AcademicYear.for_date(Time.current) || create(:academic_year, :current)
    previous_year_starts_on = @current_academic_year.starts_on - 1.year
    previous_year_ends_on = @current_academic_year.starts_on - 1.day
    @previous_academic_year = AcademicYear.for_date(Time.current - 1.year) || create(:academic_year,
                                                                                     starts_on: previous_year_starts_on,
                                                                                     ends_on: previous_year_ends_on,
                                                                                     name: "#{previous_year_starts_on.year} to #{previous_year_ends_on.year}")

    current_claim_window = create(:claim_window, academic_year: @current_academic_year,
                                                 starts_on: @current_academic_year.starts_on,
                                                 ends_on: @current_academic_year.starts_on + 2.days)
    previous_claim_window = create(:claim_window,
                                   academic_year: @previous_academic_year,
                                   starts_on: @previous_academic_year.starts_on,
                                   ends_on: @previous_academic_year.starts_on + 2.days)
    @current_claim = create(:claim,
                            :submitted,
                            status: :sampling_in_progress,
                            claim_window: current_claim_window)
    @previous_claim = create(:claim,
                             :submitted,
                             status: :sampling_in_progress,
                             claim_window: previous_claim_window)
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
    expect(page).to have_h2("Auditing (1)")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def and_i_see_the_sampled_claim_for_the_current_academic_year
    expect(page).to have_claim_card({
      "title" => "#{@current_claim.reference} - #{@current_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@current_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @current_claim.academic_year.name,
      "provider_name" => @current_claim.provider_name,
      "submitted_at" => I18n.l(@current_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def and_i_see_the_sampled_claim_for_the_previous_academic_year
    expect(page).to have_claim_card({
      "title" => "#{@previous_claim.reference} - #{@previous_claim.school.name}",
      "url" => "/support/claims/sampling/claims/#{@previous_claim.id}",
      "status" => "Sampling in progress",
      "academic_year" => @previous_claim.academic_year.name,
      "provider_name" => @previous_claim.provider_name,
      "submitted_at" => I18n.l(@previous_claim.submitted_at.to_date, format: :long),
      "amount" => "£0.00",
    })
  end

  def when_i_select_the_previous_year_from_the_academic_year_filter
    choose @previous_claim.academic_year.name
  end
  alias_method :and_i_select_the_previous_year_from_the_academic_year_filter,
               :when_i_select_the_previous_year_from_the_academic_year_filter

  def when_i_select_the_current_year_from_the_academic_year_filter
    choose @current_claim.academic_year.name
  end
  alias_method :and_i_select_the_current_year_from_the_academic_year_filter,
               :when_i_select_the_current_year_from_the_academic_year_filter

  def and_i_click_on_apply_filters
    click_on "Apply filters"
  end

  def and_i_do_not_see_the_sampled_claim_for_the_current_academic_year
    expect(page).not_to have_claim_card(
      { "title" => "#{@current_claim.reference} - #{@current_claim.school_name}" },
    )
  end

  def and_i_do_not_see_the_sampled_claim_for_the_previous_academic_year
    expect(page).not_to have_claim_card(
      { "title" => "#{@previous_claim.reference} - #{@previous_claim.school_name}" },
    )
  end

  def and_i_see_previous_academic_year_is_selected_from_the_academic_year_filter
    expect(page).to have_element(:legend, text: "Academic year", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field(@previous_academic_year.name)
    expect(page).to have_filter_tag(@previous_academic_year.name)
  end

  def and_i_see_current_academic_year_is_selected_from_the_academic_year_filter
    expect(page).to have_element(:legend, text: "Academic year", class: "govuk-fieldset__legend")
    expect(page).to have_checked_field(@current_academic_year.name)
    expect(page).to have_filter_tag(@current_academic_year.name)
  end

  def and_i_do_not_see_current_academic_year_selected_from_the_academic_year_filter
    expect(page).not_to have_checked_field(@current_academic_year.name)
    expect(page).not_to have_filter_tag(@current_academic_year.name)
  end

  def and_i_do_not_see_previous_academic_year_selected_from_the_academic_year_filter
    expect(page).not_to have_checked_field(@previous_academic_year.name)
    expect(page).not_to have_filter_tag(@previous_academic_year.name)
  end

  def when_i_click_on_the_current_academic_year_filter_tag
    within ".app-filter-tags" do
      click_on @current_academic_year.name
    end
  end

  def when_i_click_clear_filters
    click_on "Clear filters"
  end
end
