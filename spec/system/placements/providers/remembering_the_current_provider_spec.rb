require "rails_helper"

RSpec.describe "Remembering the current provider", service: :placements, type: :system do
  let(:provider_one) { build(:placements_provider, name: "The Chalkboard Champions") }
  let(:provider_two) { build(:placements_provider, name: "Ctrl + Alt + Teach") }

  scenario "A multi-org user switches between different providers" do
    given_i_am_signed_in_as_a_placements_user(organisations: [provider_one, provider_two])

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

  def when_i_click_on(text)
    click_on text
  end
  alias_method :and_i_click_on, :when_i_click_on

  def then_my_current_provider_is(provider_name)
    expect(page).to have_css(".content-header-title", text: provider_name)
  end
end
