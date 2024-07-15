require "rails_helper"

RSpec.describe "Remove a claim window", freeze: "17 July 2024", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user removes a claim window" do
    given_there_is_a_claim_window(starts_on: "18 July 2024", ends_on: "31 July 2024")

    when_i_visit_the_claim_windows_page
    then_i_see("18 July 2024 to 31 July 2024")

    when_i_click_on("18 July 2024 to 31 July 2024")
    and_i_click_on("Remove claim window")
    then_i_see_a_confirmation_page

    when_i_click_on("Remove claim window")
    then_i_see_the_claim_window_removed_successfully_without(start_date: "18 July 2024", end_date: "31 July 2024")
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_there_is_a_claim_window(starts_on:, ends_on:)
    Claims::ClaimWindow::Build.call(claim_window_params: { starts_on:, ends_on: }).save!(validate: false)
  end

  def when_i_visit_the_claim_windows_page
    click_on "Settings"
    click_on "Claim windows"
  end

  alias_method :and_i_click_on, :click_on
  alias_method :when_i_click_on, :click_on

  def then_i_see(content)
    expect(page).to have_content(content)
  end

  def then_i_see_a_confirmation_page
    expect(page).to have_content("18 July 2024 to 31 July 2024")
    expect(page).to have_content("Are you sure you want to remove this claim window?")
  end

  def then_i_see_the_claim_window_removed_successfully_without(start_date:, end_date:)
    expect(page).to have_content("Claim window removed")
    expect(page).not_to have_content("#{start_date} to #{end_date}")
  end
end
