require "rails_helper"

RSpec.describe "Service updates page", service: :claims, type: :system do
  before do
    allow(MarkdownDocument).to receive(:from_directory).and_return([
      MarkdownDocument.from_file(file_fixture("service_update.md")),
    ])
  end

  scenario "View all service updates" do
    when_i_visit_the_service_updates_page
    then_i_see_all_service_updates
  end

  private

  def when_i_visit_the_service_updates_page
    visit "/service-updates"
  end

  def then_i_see_all_service_updates
    expect(page).to have_content("News and updates")

    expect(page).to have_content("Service Update")
    expect(page).to have_content("2 May 2024")
    expect(page).to have_content("Lorem ipsum dolor sit amet, consectetur adipiscing elit.")
  end
end
