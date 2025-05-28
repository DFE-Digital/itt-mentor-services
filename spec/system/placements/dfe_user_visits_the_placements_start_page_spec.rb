require "rails_helper"

RSpec.describe "DfE user visits the placements start page", service: :placements, type: :system do
  include ActionView::Helpers::SanitizeHelper

  scenario do
    given_i_am_on_the_placements_service_start_page
    then_i_see_the_start_page_detail
    and_i_see_the_start_now_button

    when_i_click_on("Start now")
    then_i_can_see_the_dfe_sign_in_button
  end

  private

  def given_i_am_on_the_placements_service_start_page
    # The user does not need to sign in, and we need to navigate somewhere to start the process
    visit placements_root_path

    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Manage school placements")
    expect(page).to have_element(:p, text: "Use this service if you are involved in arranging school placements for trainee teachers in England.", class: "govuk-body-m")
  end

  def then_i_see_the_start_page_detail
    markdown = File.read(Rails.root.join("app/views/placements/pages/landing-page.md"))
    content = GovukMarkdown.render(markdown, headings_start_with: "l").html_safe

    strip_tags(content).split("\n").each do |paragraph|
      next if paragraph.blank?

      expect(page).to have_content paragraph.strip
    end

    expect(page).to have_h3("Related content")
    expect(page).to have_link(
      "Guidance on what schools need to do to offer trainee teacher placements",
      href: "https://www.gov.uk/guidance/offer-a-trainee-teacher-placement",
    )
    expect(page).to have_link(
      "Guidance on how to find or request a TRN",
      href: "https://www.gov.uk/guidance/teacher-reference-number-trn",
    )
  end

  def and_i_see_the_start_now_button
    expect(page).to have_element(:a, text: "Start now", class: "govuk-button")
  end

  def when_i_click_on(text)
    click_on text
  end

  def then_i_can_see_the_dfe_sign_in_button
    expect(page).to have_element(:button, text: "Sign in using DfE Sign In", class: "govuk-button")
  end
end
