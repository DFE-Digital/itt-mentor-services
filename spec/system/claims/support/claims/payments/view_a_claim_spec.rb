require "rails_helper"

RSpec.describe "View claims", service: :claims, type: :system do
  scenario do
    given_i_sign_in
    when_i_visit_claims_payments_index_page
    and_i_click_on_the_claim
    then_i_can_see_the_details_of_claim

    when_i_click_on_the_school_details_tab
    then_i_can_see_the_details_of_the_school

    when_i_click_on_the_school_users_tab
    then_i_can_see_the_school_users

    when_i_click_on_the_claim_history_tab
    then_i_can_see_the_claim_history
  end

  private

  def given_i_sign_in
    sign_in_claims_support_user
    @school_user = create(:claims_user,
                          first_name: "Sarah",
                          last_name: "Smith",
                          email: "sarah.smith@hogwarts.ac.uk",
                          last_signed_in_at: 1.day.ago)
    @school = create(:claims_school, name: "Hogwarts", urn: "123456", users: [@school_user])
    @claim = create(:claim, :payment_information_requested, unpaid_reason: "Some reason", school: @school)
  end

  def when_i_visit_claims_payments_index_page
    click_on("Claims")
    click_on("Payments")
  end

  def and_i_click_on_the_claim
    click_on @school.name
  end

  def then_i_can_see_the_details_of_claim
    expect(page).to have_content("Claim #{@claim.reference}")
    expect(page).to have_content("Payer needs information")
    expect(page).to have_content("School#{@claim.school_name}")
    expect(page).to have_content("Academic year#{@claim.academic_year_name}")
    expect(page).to have_content("Accredited provider#{@claim.provider_name}")

    within(".govuk-inset-text") do
      expect(page).to have_content("Some reason")
    end
  end

  def when_i_click_on_the_school_details_tab
    click_on "School details"
  end

  def then_i_can_see_the_details_of_the_school
    expect(page).to have_h1("School details")

    expect(page).to have_summary_list_row("Name", "Hogwarts")
    expect(page).to have_summary_list_row("Unique reference number (URN)", "123456")
  end

  def when_i_click_on_the_school_users_tab
    click_on "School users"
  end

  def then_i_can_see_the_school_users
    expect(page).to have_h1("School users")

    expect(page).to have_table_row({
      "Name" => "Sarah Smith",
      "Email" => "sarah.smith@hogwarts.ac.uk",
      "Last signed in" => 1.day.ago.strftime("%d %b %H:%M"),
    })
  end

  def when_i_click_on_the_claim_history_tab
    click_on "History"
  end

  def then_i_can_see_the_claim_history
    expect(page).to have_h1("History")

    expect(page).to have_paragraph("There is no activity.")
  end
end
