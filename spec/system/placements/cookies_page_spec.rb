require "rails_helper"

RSpec.describe "Start Page", service: :placements, type: :system do
  include ActionView::Helpers::SanitizeHelper

  scenario "User views the cookies page" do
    when_i_visit_the_cookies_page
    then_i_see_cookie_page_details
  end

  private

  def when_i_visit_the_cookies_page
    visit placements_cookies_path
  end

  def then_i_see_cookie_page_details
    markdown = File.read(Rails.root.join("app/views/placements/pages/cookies.md"))
    content = GovukMarkdown.render(markdown, headings_start_with: "l").html_safe

    strip_tags(content).split("\n").each do |paragraph|
      next if paragraph.blank?

      expect(page).to have_content(paragraph.strip)
    end
  end
end
