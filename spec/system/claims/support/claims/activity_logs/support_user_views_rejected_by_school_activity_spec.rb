require "rails_helper"

RSpec.describe "Support user views rejected by school activity spec", service: :claims, type: :system do
  scenario do
    given_rejected_by_school_activity_exists
    and_i_am_signed_in
    then_i_see_the_organisations_page

    when_i_click_on_claims
    then_i_see_the_claims_page

    when_i_click_on_activity_log
    then_i_see_the_activity_log_page

    when_i_click_on_view_details
    then_i_see_the_activity_details
  end

  def given_rejected_by_school_activity_exists
    @colin = build(:claims_support_user, :colin)

    @best_practice_network = build(:claims_provider, name: "Best Practice Network")
    @best_practice_network_claim = build(:claim, :payment_in_progress, submitted_at: 1.day.ago, reference: "12345678", provider: @best_practice_network)

    @activity_log = create(:claim_activity, :rejected_by_school, user: @colin, record: @best_practice_network_claim)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations (1) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (1)")
  end

  def when_i_click_on_claims
    click_on("Claims")
  end

  def then_i_see_the_claims_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(secondary_navigation).to have_current_item("All claims")
  end

  def when_i_click_on_activity_log
    click_on("Activity log")
  end

  def then_i_see_the_activity_log_page
    expect(page).to have_title("Claims - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Claims")
    expect(secondary_navigation).to have_current_item("Activity log")
    expect(page).to have_h2("Activity log")
    expect(page).to have_element("h3", class: "app-timeline__title", text: "School #{@best_practice_network_claim.school_name} rejected audit for claim 12345678")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@activity_log))
  end

  def when_i_click_on_view_details
    click_on("View details")
  end

  def then_i_see_the_activity_details
    expect(page).to have_title("School #{@best_practice_network_claim.school_name} rejected audit for claim 12345678 - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("School #{@best_practice_network_claim.school_name} rejected audit for claim 12345678")
    expect(page).to have_link("12345678", href: claims_support_claim_path(@best_practice_network_claim))
    expect(page).to have_h2("Providers")
    expect(page).to have_h3("Best Practice Network")
    expect(page).to have_table_row({
      "Claim reference" => "12345678",
      "Number of mentors" => "0",
      "Claim amount" => "£#{@best_practice_network_claim.amount}",
    })
  end
end
