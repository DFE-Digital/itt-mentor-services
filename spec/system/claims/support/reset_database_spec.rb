require "rails_helper"

RSpec.describe "Reset claims database", service: :claims, type: :system do
  let(:support_user) { create(:claims_support_user) }

  before do
    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user resets claims database for testing purposes" do
    when_i_visit_the_reset_database_page
    then_i_see "Are you sure you want to reset the Test database?"

    when_i_click_on "Reset database"
    then_i_see "Database has been reset"
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_reset_database_page
    click_on "Settings"
    click_on "Reset database"
  end

  alias_method :when_i_click_on, :click_on

  def then_i_see(content)
    expect(page).to have_content(content)
  end
end
