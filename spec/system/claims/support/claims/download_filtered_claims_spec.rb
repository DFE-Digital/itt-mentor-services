require "rails_helper"

RSpec.describe "Download filtered claims", type: :system, service: :claims do
  let(:support_user) { create(:claims_support_user) }
  let(:school) { create(:claims_school, :claims, name: "School name 1", urn: "1234") }
  let(:another_school) { create(:claims_school, :claims, name: "School name 1", urn: "1235") }
  let!(:niot) { create(:claims_provider, :niot) }
  let!(:best_practice_network) { create(:claims_provider, :best_practice_network) }

  let!(:best_practice_network_claim_1) { create(:claim, :submitted, provider: best_practice_network, school_id: another_school.id, reference: "12345676") }
  let!(:best_practice_network_claim_2) { create(:claim, :submitted, provider: best_practice_network, school_id: another_school.id, reference: "12345675") }

  before do
    create(:claim, :submitted, provider: niot, school_id: school.id, reference: "12345678")
    create(:claim, :submitted, provider: niot, school_id: school.id, reference: "12345677")

    user_exists_in_dfe_sign_in(user: support_user)
    given_i_sign_in
  end

  scenario "Support user visits the claims index page and filters the claims and then downloads CSV using the same filters" do
    given_i_am_on_the_claims_index_page
    when_i_filter_the_claims_by_provider(best_practice_network)
    then_the_filter_returns_only_the_best_practice_network_claims([best_practice_network_claim_1, best_practice_network_claim_2], best_practice_network)
    when_i_click_download_claims
    then_i_expect_to_use_the_same_query_params_to_download_claims_as_when_i_was_filtering_claims(best_practice_network)
  end

  private

  def given_i_sign_in
    visit sign_in_path
    click_on "Sign in using DfE Sign In"
  end

  def given_i_am_on_the_claims_index_page
    click_on("Claims")
  end

  def when_i_filter_the_claims_by_provider(provider)
    page.find("#claims-support-claims-filter-form-provider-ids-#{provider.id}-field", visible: :all).check
    click_on("Apply filters")
  end

  def then_the_filter_returns_only_the_best_practice_network_claims(claims, provider)
    expect(claims.count).to eq(page.find_all(".claim-card").count)

    uri = URI.parse(page.current_url)
    query_parameters = CGI.parse(uri.query)

    expect(query_parameters["claims_support_claims_filter_form[provider_ids][]"]).to eq(["", provider.id])
  end

  def when_i_click_download_claims
    click_on("Download CSV")
  end

  def then_i_expect_to_use_the_same_query_params_to_download_claims_as_when_i_was_filtering_claims(provider)
    uri = URI.parse(page.current_url)
    query_parameters = CGI.parse(uri.query)

    expect(query_parameters["claims_support_claims_filter_form[provider_ids][]"]).to eq(["", provider.id])
  end
end
