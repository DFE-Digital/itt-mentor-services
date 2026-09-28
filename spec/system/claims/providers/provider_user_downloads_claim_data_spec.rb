require "rails_helper"

RSpec.describe "Provider user downloads claim data", service: :claims, type: :system do
  scenario "provider user downloads claims across academic years from their account page" do
    given_claims_exist_for_my_provider_across_academic_years
    and_i_am_signed_in_as_a_provider_user
    when_i_visit_my_account_page
    then_i_see_the_download_claim_data_button

    when_i_click_on_download_claim_data
    then_i_receive_a_csv_of_my_claims
  end

  scenario "school user does not see the download claim data button" do
    given_i_am_signed_in_as_a_school_user
    when_i_visit_my_account_page
    then_i_do_not_see_the_download_claim_data_button
  end

  scenario "support user does not see the download claim data button" do
    given_i_am_signed_in_as_a_claims_support_user
    when_i_visit_my_account_page
    then_i_do_not_see_the_download_claim_data_button
  end

  private

  def given_claims_exist_for_my_provider_across_academic_years
    @provider = create(:claims_provider, name: "North Star SCITT")
    @school = create(:claims_school, name: "Riverbank Primary", urn: "123456")
    @mentor_barry = create(:claims_mentor, first_name: "Barry", last_name: "Garlow")

    @historic_claim_window = create(:claim_window, :historic)
    @current_claim_window = create(:claim_window, :current)

    create(
      :claim,
      :submitted,
      provider: @provider,
      school: @school,
      claim_window: @historic_claim_window,
      reference: "9000001",
      mentor_trainings: [build(:mentor_training, mentor: @mentor_barry, provider: @provider, hours_completed: 12)],
    )
    create(
      :claim,
      :submitted,
      status: :paid,
      provider: @provider,
      school: @school,
      claim_window: @current_claim_window,
      reference: "9000002",
      mentor_trainings: [build(:mentor_training, mentor: @mentor_barry, provider: @provider, hours_completed: 5)],
    )
  end

  def and_i_am_signed_in_as_a_provider_user
    @provider_user = create(:claims_provider_user, :patricia, providers: [@provider])
    sign_in_as(@provider_user)
  end

  def given_i_am_signed_in_as_a_school_user
    @school_user = create(:claims_user, schools: [create(:claims_school)])
    sign_in_as(@school_user)
  end

  def when_i_visit_my_account_page
    visit account_path
  end

  def then_i_see_the_download_claim_data_button
    expect(page).to have_title("Your account - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Your account")
    expect(page).to have_link("Download claim data", href: "/providers/#{@provider.id}/claims/download")
  end

  def then_i_do_not_see_the_download_claim_data_button
    expect(page).to have_h1("Your account")
    expect(page).not_to have_link("Download claim data")
  end

  def when_i_click_on_download_claim_data
    click_on "Download claim data"
  end

  def then_i_receive_a_csv_of_my_claims
    expect(page.response_headers["Content-Disposition"]).to include(
      "attachment; filename=\"claims_funding_for_mentor_training_claims_#{Date.current.iso8601}.csv\"",
    )
    expect(page.response_headers["Content-Type"]).to include("text/csv")

    csv = CSV.parse(page.body, headers: true)
    expect(csv.headers).to eq(%w[academic_year school_urn school_name claim_reference mentor_first_name mentor_last_name hours_claimed])
    expect(csv.map(&:fields)).to eq([
      [@historic_claim_window.academic_year_name, "123456", "Riverbank Primary", "9000001", "Barry", "Garlow", "12"],
      [@current_claim_window.academic_year_name, "123456", "Riverbank Primary", "9000002", "Barry", "Garlow", "5"],
    ])
  end
end
