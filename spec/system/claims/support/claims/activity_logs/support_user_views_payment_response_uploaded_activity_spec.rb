require "rails_helper"

RSpec.describe "Support user views payment response uploaded activity spec", service: :claims, type: :system do
  scenario do
    given_payment_response_uploaded_activity_exists
    and_i_am_signed_in
    then_i_see_the_organisations_page

    when_i_click_on_claims
    then_i_see_the_claims_page

    when_i_click_on_activity_log
    then_i_see_the_activity_log_page

    when_i_click_on_view_details
    then_i_see_the_activity_details

    when_i_click_on_download_csv
    then_i_receive_a_csv_file
  end

  def given_payment_response_uploaded_activity_exists
    @colin = build(:claims_support_user, :colin)
    @payment_response = build(:claims_payment_response)
    @activity_log = create(:claim_activity, :payment_response_uploaded, user: @colin, record: @payment_response)
  end

  def and_i_am_signed_in
    sign_in_claims_support_user
  end

  def then_i_see_the_organisations_page
    expect(page).to have_title("Organisations (0) - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Organisations (0)")
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
    expect(page).to have_element("h3", class: "app-timeline__title", text: "Payer payment response uploaded")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@activity_log))
  end

  def when_i_click_on_view_details
    click_on("View details")
  end

  def then_i_see_the_activity_details
    expect(page).to have_title("Payer payment response uploaded - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Payer payment response uploaded")
  end

  def when_i_click_on_download_csv
    click_on "Download CSV"
  end

  def then_i_receive_a_csv_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"example-payments-response.csv\"; filename*=UTF-8''example-payments-response.csv")
  end
end
