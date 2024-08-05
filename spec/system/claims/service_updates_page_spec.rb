require "rails_helper"

RSpec.describe "Service updates page", service: :claims, type: :system do
  before do
    allow(MarkdownDocument).to receive(:from_directory).and_return([
      MarkdownDocument.from_file(file_fixture("service_update.md")),
    ])
  end

  scenario "View all service updates" do
    given_i_am_on_the_start_page
    when_i_click_on_the_link_to_service_updates
    then_i_see_all_service_updates
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def when_i_click_on_the_link_to_service_updates
    click_on "View all news and updates"
  end

  def then_i_see_all_service_updates
    expect(page).to have_content("News and updates")

    expect(page).to have_content("Service Update")
    expect(page).to have_content("2 May 2024")
    expect(page).to have_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end
end
