require "rails_helper"

RSpec.describe "DfE user visits the placements start page", service: :placements, type: :system do
  include ActionView::Helpers::SanitizeHelper

  scenario do
    given_i_am_on_the_placements_service_start_page
    then_i_see_the_start_page_detail
    and_i_see_the_start_now_button

    when_i_click_on_start_now
    then_i_can_see_the_dfe_sign_in_page

    when_i_click_on_if_you_do_not_have_an_account
    then_i_see_the_details_text
  end

  private

  def given_i_am_on_the_placements_service_start_page
    # The user does not need to sign in, and we need to navigate somewhere to start the process
    visit placements_root_path

    expect(page).to have_title("Manage school placements - GOV.UK")
    expect(page).to have_h1("Manage school placements")
    expect(page).to have_paragraph("Use this service if you are involved in arranging school placements for trainee teachers in England.")
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
    expect(page).to have_link("Start now", class: "govuk-button")
  end

  def when_i_click_on_start_now
    click_on "Start now"
  end

  def then_i_can_see_the_dfe_sign_in_page
    expect(page).to have_paragraph("This is a pilot service for schools and teacher training providers in Leeds and Essex.")
    expect(page).to have_paragraph("Access your account using DfE Sign-In.")
    expect(page).to have_element(:span, class: "govuk-details__summary-text", text: "If you do not have an account")
    expect(page).to have_button("Sign in using DfE Sign In")
  end

  def when_i_click_on_if_you_do_not_have_an_account
    find("span.govuk-details__summary-text", text: "If you do not have an account").click
  end

  def then_i_see_the_details_text
    expect(page).to have_paragraph("Colleagues in your organisation can add you if they have an account.")
    expect(page).to have_paragraph("If your organisation has not been set up to use this service, email Manage.SchoolPlacements@education.gov.uk.")
    expect(page).to have_paragraph("DfE Sign-In may be different from sign-in for other services.")
  end
end
