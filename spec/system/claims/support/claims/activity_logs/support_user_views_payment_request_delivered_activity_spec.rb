require "rails_helper"

RSpec.describe "Support user views payment request delivered activity spec",
               freeze: "01 July 2025",
               service: :claims,
               type: :system do
  scenario do
    given_payment_request_delivered_activity_exists
    and_i_am_signed_in
    then_i_see_the_organisations_page

    when_i_click_on_claims
    then_i_see_the_claims_page

    when_i_click_on_activity_log
    then_i_see_the_activity_log_page

    when_i_click_on_view_details
    then_i_see_the_activity_details

    when_i_click_on_resend_email_to_payer
    then_i_see_the_email_sent_success_message

    when_i_click_on_download_csv
    then_i_receive_a_csv_file
  end

  def given_payment_request_delivered_activity_exists
    @colin = build(:claims_support_user, :colin)

    @best_practice_network = build(:claims_provider, name: "Best Practice Network")
    @best_practice_network_claim = build(:claim, :payment_in_progress, submitted_at: 1.day.ago, reference: "12345678", provider: @best_practice_network)

    @niot = build(:claims_provider, name: "National Institute of Technology")
    @niot_claim = build(:claim, :payment_in_progress, submitted_at: 1.day.ago, reference: "87654321", provider: @niot)

    @payment = build(:claims_payment, claims: [@best_practice_network_claim, @niot_claim])
    @activity_log = create(:claim_activity, :payment_request_delivered, user: @colin, record: @payment)

    allow(Claims::Payment::ResendEmail).to receive(:call).and_call_original
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations (2) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (2)")
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
    expect(page).to have_element("h3", class: "app-timeline__title", text: "2 claims sent to payer for payment")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@activity_log))
  end

  def when_i_click_on_view_details
    click_on("View details")
  end

  def then_i_see_the_activity_details
    expect(page).to have_title("2 claims sent to payer for payment - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("2 claims sent to payer for payment")
    expect(page).to have_link("12345678", href: claims_support_claim_path(@best_practice_network_claim))
    expect(page).to have_link("Resend email to payer", href: resend_payer_email_claims_support_claims_claim_activity_path(@activity_log))
    expect(page).to have_h2("Providers")
    expect(page).to have_h3("Best Practice Network")
    expect(page).to have_table_row({
      "Claim reference" => "12345678",
      "Number of mentors" => "0",
      "Claim amount" => "£#{@best_practice_network_claim.amount}",
    })

    expect(page).to have_h3("National Institute of Technology")
    expect(page).to have_table_row({
      "Claim reference" => "87654321",
      "Number of mentors" => "0",
      "Claim amount" => "£#{@niot_claim.amount}",
    })
  end

  def when_i_click_on_resend_email_to_payer
    click_on("Resend email to payer")
  end

  def then_i_see_the_email_sent_success_message
    expect(Claims::Payment::ResendEmail).to have_received(:call).once
    expect(page).to have_success_banner("An email has been sent to the payer")
  end

  def when_i_click_on_download_csv
    click_on "Download CSV"
  end

  def then_i_receive_a_csv_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to eq(
      "attachment; filename=\"payment-claims-#{Time.current.strftime("%Y-%m-%d")} 00-00-00 UTC.csv\"; filename*=UTF-8''payment-claims-#{Time.current.strftime("%Y-%m-%d")}%2000-00-00%20UTC.csv",
    )
  end
end
