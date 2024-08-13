require "rails_helper"

RSpec.describe "View claims", :js, service: :claims, type: :system do
  let!(:support_user) { create(:claims_support_user) }
  let!(:school_1) { create(:claims_school) }
  let!(:school_2) { create(:claims_school) }
  let!(:provider_1) { create(:claims_provider, :best_practice_network) }
  let!(:provider_2) { create(:claims_provider, :niot) }
  let!(:claim_1) { create(:claim, :draft, school: school_1) }
  let!(:claim_2) { create(:claim, :submitted, school: school_1, provider: provider_1, submitted_at: Date.new(2024, 4, 7), created_at: Date.new(2024, 4, 7)) }
  let!(:claim_3) { create(:claim, :submitted, school: school_1, provider: provider_1, submitted_at: Date.new(2024, 4, 6), created_at: Date.new(2024, 4, 6)) }
  let!(:claim_4) { create(:claim, :submitted, school: school_1, provider: provider_1, submitted_at: Date.new(2024, 4, 5), created_at: Date.new(2024, 4, 5)) }
  let!(:claim_5) { create(:claim, :submitted, school: school_1, provider: provider_1, submitted_at: Date.new(2024, 4, 4), created_at: Date.new(2024, 4, 4)) }
  let!(:claim_6) { create(:claim, :submitted, school: school_1, provider: provider_2, submitted_at: Date.new(2024, 4, 3), created_at: Date.new(2024, 4, 3)) }
  let!(:claim_7) { create(:claim, :submitted, school: school_2, provider: provider_2, submitted_at: Date.new(2024, 4, 2), created_at: Date.new(2024, 4, 2)) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page" do
    when_i_visit_claim_index_page
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
    and_i_see_no_draft_claims
    when_i_check_school_filter(school_1)
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6])
    when_i_check_provider_filter(provider_1)
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5])
    when_i_set_submitted_after(5, 4, 2024)
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4])
    when_i_set_submitted_before(6, 4, 2024)
    then_i_see_a_list_of_claims([claim_3, claim_4])
    when_i_search_for_claim_reference(claim_3.reference)
    then_i_see_a_list_of_claims([claim_3])
    when_i_remove_my_search
    then_i_see_a_list_of_claims([claim_3, claim_4])
    when_i_remove_the_filter("06/04/2024")
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4])
    when_i_remove_the_filter("05/04/2024")
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5])
    when_i_remove_the_filter(provider_1.name)
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6])
    when_i_remove_the_filter(school_1.name)
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
  end

  context "when filtering by a status" do
    scenario "Support user filters claims in a submitted status" do
      when_i_visit_claim_index_page
      then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
      and_i_see_no_draft_claims
      when_i_check_status_filter("Submitted")
      then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
      when_i_remove_the_filter("Submitted")
      then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
    end
  end

  scenario "Support user uses the js filter search" do
    when_i_visit_claim_index_page
    then_i_see_a_list_of_claims([claim_2, claim_3, claim_4, claim_5, claim_6, claim_7])
    when_i_search_the_school_filter_with(school_2.name)
    then_i_see_only_my_filter_school_as_an_option
    when_i_check_school_filter(school_2)
    then_i_see_a_list_of_claims([claim_7])
    when_i_search_the_provider_filter_with(provider_2.name)
    when_i_check_provider_filter(provider_2)
    then_i_see_a_list_of_claims([claim_7])
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_claim_index_page
    click_on("Claims")
  end

  def then_i_see_a_list_of_claims(claims)
    claims.each_with_index do |claim, index|
      within(".claim-card:nth-child(#{index + 1})") do
        expect(page).to have_content(claim.school.name)
        expect(page).to have_content(claim.reference)
        expect(page).to have_content("Submitted")
        expect(page).to have_content(claim.provider.name)
        expect(page).to have_content(I18n.l(claim.submitted_at.to_date, format: :short))
        expect(page).to have_content(claim.amount.format(no_cents_if_whole: true))
      end
    end
    expect(claims.count).to eq(page.find_all(".claim-card").count)
  end

  def and_i_see_no_draft_claims
    expect(page).not_to have_content(claim_1.reference)
  end

  def when_i_check_school_filter(school)
    page.find("#claims-support-claims-filter-form-school-ids-#{school.id}-field", visible: :all).check
    click_on("Apply filters")
  end

  def when_i_check_provider_filter(provider)
    page.find("#claims-support-claims-filter-form-provider-ids-#{provider.id}-field", visible: :all).check
    click_on("Apply filters")
  end

  def when_i_check_status_filter(status)
    page.find("#claims-support-claims-filter-form-statuses-#{status.downcase}-field", visible: :all).check
    click_on("Apply filters")
  end

  def when_i_set_submitted_after(day, month, year)
    within_fieldset("Submitted after") do
      fill_in("Day", with: day)
      fill_in("Month", with: month)
      fill_in("Year", with: year)
    end
    click_on("Apply filters")
  end

  def when_i_set_submitted_before(day, month, year)
    within_fieldset("Submitted before") do
      fill_in("Day", with: day)
      fill_in("Month", with: month)
      fill_in("Year", with: year)
    end
    click_on("Apply filters")
  end

  def when_i_search_for_claim_reference(reference)
    fill_in("Search by claim reference", with: reference)
    click_on("Search")
  end

  def when_i_remove_my_search
    fill_in("Search by claim reference", with: nil)
    click_on("Search")
  end

  def when_i_remove_the_filter(filter)
    within(".app-filter-layout__selected") do
      click_link(filter)
    end
  end

  def when_i_search_the_school_filter_with(school_name)
    find("legend", text: "School").sibling("input[type=search]").fill_in(with: school_name)
  end

  def when_i_search_the_provider_filter_with(provider_name)
    find("legend", text: "Accredited provider").sibling("input[type=search]").fill_in(with: provider_name)
  end

  def then_i_see_only_my_filter_school_as_an_option
    my_selection = page.find("#claims-support-claims-filter-form-school-ids-#{school_2.id}-field", visible: :all)
    expect(my_selection.present?).to be(true)

    other_school_option = page.find_all("#claims-support-claims-filter-form-school-ids-#{school_1.id}-field", wait: false)
    expect(other_school_option.blank?).to be(true)
  end
end
