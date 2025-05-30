require "rails_helper"

RSpec.describe "User views the accessibility page", service: :placements, type: :system do
  include ActionView::Helpers::SanitizeHelper

  scenario do
    given_i_am_on_the_placements_service_start_page
    and_i_click_on_the_accessibility_page_link
    then_i_see_accessibility_page
  end

  private

  def given_i_am_on_the_placements_service_start_page
    # The user does not need to sign in, and we need to navigate somewhere to start the process
    visit placements_root_path

    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Manage school placements")
    expect(page).to have_paragraph("Use this service if you are involved in arranging school placements for trainee teachers in England.")
  end

  def and_i_click_on_the_accessibility_page_link
    click_on "Accessibility"
  end

  def then_i_see_accessibility_page
    markdown = File.read(Rails.root.join("app/views/placements/pages/accessibility.md"))
    content = GovukMarkdown.render(markdown, headings_start_with: "l").html_safe

    strip_tags(content).split("\n").each do |paragraph|
      next if paragraph.blank?

      expect(page).to have_content paragraph.strip
    end
  end
end
