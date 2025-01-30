require "rails_helper"

RSpec.describe "Support user views sampling response uploaded activity spec", service: :claims, type: :system do
  scenario do
    given_sampling_response_uploaded_activity_exists
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

  def given_sampling_response_uploaded_activity_exists
    @colin = build(:claims_support_user, :colin)
    @provider = build(:claims_provider, name: "Best Practice Network")
    @claim = build(:claim, :audit_requested, submitted_at: 1.day.ago, reference: "12345678", provider: @provider)
    @provider_sampling = build(:provider_sampling, provider: @provider, claims: [@claim])
    @sampling = build(:claims_sampling, provider_samplings: [@provider_sampling])
    @activity_log = create(:claim_activity, :sampling_response_uploaded, user: @colin, record: @sampling)
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
    expect(page).to have_element("h3", class: "app-timeline__title", text: "Provider audit response uploaded")
    expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@activity_log))
  end

  def when_i_click_on_view_details
    click_on("View details")
  end

  def then_i_see_the_activity_details
    expect(page).to have_title("Provider audit response uploaded - Claim funding for mentor training - GOV.UK")
    expect(primary_navigation).to have_current_item("Claims")
    expect(page).to have_h1("Provider audit response uploaded")
    expect(page).to have_h2("Providers")
    expect(page).to have_h3("Best Practice Network")
    expect(page).to have_table_row({
      "Claim reference" => "12345678",
      "Number of mentors" => "0",
      "Claim amount" => "£#{@claim.amount}",
    })
    expect(page).to have_link("12345678", href: claims_support_claim_path(@claim))
  end

  def when_i_click_on_download_csv
    click_on "Download CSV"
  end

  def then_i_receive_a_csv_file
    expect(page.response_headers["Content-Type"]).to eq("text/csv")
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"example-sampling-response.csv\"; filename*=UTF-8''example-sampling-response.csv")
  end
end
