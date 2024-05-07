require "rails_helper"

RSpec.describe "Start Page", type: :system, service: :placements do
  include ActionView::Helpers::SanitizeHelper

  scenario "User visits the placements homepage with dfe sign in" do
    given_i_am_on_the_start_page
    then_i_can_see_the_placements_service_name_in_the_header
    and_i_see_the_start_page_detail
    and_i_see_the_start_now_button
    when_i_click_on("Start now")
    then_i_can_see_the_dfe_sign_in_button
  end

  scenario "User visits the placements homepage with person sign in", persona_sign_in: true do
    given_i_am_on_the_start_page
    then_i_can_see_the_placements_service_name_in_the_header
    and_i_see_the_start_page_detail
    and_i_see_the_start_now_button
    when_i_click_on("Start now")
    then_i_can_see_the_persona_sign_in_button
  end

  private

  def given_i_am_on_the_start_page
    visit "/"
  end

  def then_i_can_see_the_placements_service_name_in_the_header
    within(".govuk-header") do
      expect(page).to have_content("Manage school placements")
    end
  end

  def then_i_can_see_the_dfe_sign_in_button
    expect(page).to have_content("Sign in using DfE Sign In")
  end

  def then_i_can_see_the_persona_sign_in_button
    expect(page).to have_content("Sign in using a Persona")
  end

  def and_i_see_the_start_now_button
    expect(page).to have_content("Start now")
  end

  def when_i_click_on(text)
    click_on text
  end

  def and_i_see_the_start_page_detail
    markdown = File.read(Rails.root.join("app/views/placements/pages/landing-page.md"))
    content = GovukMarkdown.render(markdown, headings_start_with: "l").html_safe

    strip_tags(content).split("\n").each do |paragraph|
      next if paragraph.blank?

      expect(page).to have_content(paragraph.strip)
    end

    expect(page).to have_content("Related content")
    expect(page).to have_link(
      "Guidance on what schools need to do to offer trainee teacher placements",
      href: "https://www.gov.uk/guidance/offer-a-trainee-teacher-placement",
    )
    expect(page).to have_link(
      "Guidance on how to find or request a TRN",
      href: "https://www.gov.uk/guidance/teacher-reference-number-trn",
    )
  end
end
