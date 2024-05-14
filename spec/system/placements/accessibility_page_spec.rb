require "rails_helper"

RSpec.describe "Accessibility Page", type: :system, service: :placements do
  include ActionView::Helpers::SanitizeHelper

  scenario "User views the accessibility page" do
    when_i_visit_the_accessibility_page
    then_i_see_accessibility_page_details
  end

  private

  def when_i_visit_the_accessibility_page
    visit placements_accessibility_path
  end

  def then_i_see_accessibility_page_details
    markdown = File.read(Rails.root.join("app/views/placements/pages/accessibility.md"))
    content = GovukMarkdown.render(markdown, headings_start_with: "l").html_safe

    strip_tags(content).split("\n").each do |paragraph|
      next if paragraph.blank?

      expect(page).to have_content(paragraph.strip)
    end
  end
end
