require "rails_helper"

RSpec.describe "Support user can not upload sampling data when there are no paid claims for the current academic year",
               service: :claims,
               type: :system do
  scenario do
    given_claims_exist
    and_i_am_signed_in

    when_i_navigate_to_the_sampling_claims_index_page
    then_i_see_the_sampling_claims_index_page
    and_i_see_no_sampling_claims_have_been_uploaded

    when_i_click_on_upload_claims_to_be_sampled
    then_i_see_there_are_no_paid_claims_to_be_sampled
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

    _current_claim_window = create(:claim_window, academic_year: @current_academic_year,
                                                  starts_on: @current_academic_year.starts_on,
                                                  ends_on: @current_academic_year.starts_on + 2.days)
    previous_claim_window = create(:claim_window,
                                   academic_year: @previous_academic_year,
                                   starts_on: @previous_academic_year.starts_on,
                                   ends_on: @previous_academic_year.starts_on + 2.days)
    _previous_claim = create(:claim,
                             :submitted,
                             status: :paid,
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
      click_on "Sampling"
    end
  end

  def then_i_see_the_sampling_claims_index_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Claims")
    expect(primary_navigation).to have_current_item("Claims")
    expect(secondary_navigation).to have_current_item("Sampling")
    expect(page).to have_current_path(claims_support_claims_samplings_path, ignore_query: true)
  end

  def and_i_see_no_sampling_claims_have_been_uploaded
    expect(page).to have_h2("Sampling")
    expect(page).to have_element(:p, text: "There are no claims waiting to be processed.")
  end

  def when_i_click_on_upload_claims_to_be_sampled
    click_on "Upload claims to be sampled"
  end

  def then_i_see_there_are_no_paid_claims_to_be_sampled
    expect(page).to have_h1("You cannot upload any claims to be sampled")
    expect(page).to have_element(:span, text: "Sampling")
    expect(page).to have_element(
      :p,
      text: "You cannot upload a sampling file as there are no claims that have been paid.",
      class: "govuk-body",
    )
  end
end
