require "rails_helper"

RSpec.describe "Remembering the current provider", service: :placements, type: :system do
  let(:provider_one) { build(:placements_provider, name: "The Chalkboard Champions") }
  let(:provider_two) { build(:placements_provider, name: "Ctrl + Alt + Teach") }

  scenario "A multi-org user switches between different providers" do
    given_i_sign_in_with_access_to_multiple_providers

    when_i_click_on "The Chalkboard Champions"
    then_my_current_provider_is "The Chalkboard Champions"
    when_i_click_on "Placements"
    then_my_current_provider_is "The Chalkboard Champions"

    when_i_click_on "Change organisation"
    and_i_click_on "Ctrl + Alt + Teach"
    then_my_current_provider_is "Ctrl + Alt + Teach"
    when_i_click_on "Placements"
    then_my_current_provider_is "Ctrl + Alt + Teach"
  end

  private

  def given_i_sign_in_with_access_to_multiple_providers
    user = create(:placements_user, providers: [provider_one, provider_two])
    user_exists_in_dfe_sign_in(user:)
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_my_current_provider_is(provider_name)
    expect(page).to have_css(".content-header-title", text: provider_name)
  end
end
