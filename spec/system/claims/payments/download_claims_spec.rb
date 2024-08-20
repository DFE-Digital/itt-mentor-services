require "rails_helper"

RSpec.describe "Download claims", freeze: "27 September 2024 13:00", service: :claims, type: :system do
  let(:submitted_claims) { create_list(:claim, 3, :submitted) }

  scenario "User visits download link" do
    token = given_there_is_a_payment_with_claims
    when_i_visit_the_payment_claims_download_link(token)
    then_i_download_a_csv_of_claims
  end

  scenario "User visits download link with invalid token" do
    when_i_visit_the_payment_claims_download_link("invalid-token")
    then_i_am_see_an_error_page
  end

  scenario "User visits download link with an expired token" do
    token = given_there_is_a_payment_with_claims(expires_at: 1.day.ago)
    when_i_visit_the_payment_claims_download_link(token)
    then_i_am_see_an_error_page
  end

  private

  def given_there_is_a_payment_with_claims(expires_at: 30.days.from_now)
    payment = create(:claims_payment, claim_ids: submitted_claims.pluck(:id))

    Rails.application.message_verifier(:payment).generate(payment.id, expires_at:)
  end

  def when_i_visit_the_payment_claims_download_link(token)
    visit "/payments/claims/download?token=#{token}"
  end

  def then_i_download_a_csv_of_claims
    expect(response_headers["Content-Type"]).to eq("text/csv")
    expect(response_headers["Content-Disposition"]).to eq("attachment; filename=\"claims-2024-09-27.csv\"; filename*=UTF-8''claims-2024-09-27.csv")

    submitted_claims_csv = submitted_claims.map do |claim|
      [
        claim.reference,
        claim.school.urn,
        claim.school.name,
        claim.school.local_authority_name,
        claim.amount,
        claim.school.type_of_establishment,
        claim.school.group,
        claim.submitted_at.iso8601,
        claim.status,
      ].join(",")
    end

    expect(page.body).to eq(<<~CSV)
      claim_reference,school_urn,school_name,school_local_authority,claim_amount,school_type_of_establishment,school_group,claim_submission_date,claim_status,claim_unpaid_reason
      #{submitted_claims_csv.join("\n")}
    CSV
  end

  def then_i_am_see_an_error_page
    expect(page).to have_css("h1", text: "You cannot download this file")
    expect(page).to have_content("This is because the download link has expired.")
    expect(page).to have_content("If you have any questions, please email us at ittmentor.funding@education.gov.uk")
  end
end
