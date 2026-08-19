require "rails_helper"

RSpec.describe "Provider user views claims", service: :claims, type: :system do
  let!(:provider) { create(:claims_provider, name: "North Star SCITT") }
  let!(:other_provider) { create(:claims_provider, name: "Other Provider") }
  let!(:provider_user) { create(:claims_provider_user, :patricia) }

  let!(:school) do
    create(
      :claims_school,
      name: "Riverbank Primary",
      urn: "123456",
      address1: "1 High Street",
      town: "London",
      postcode: "SW1A 1AA",
    )
  end

  let!(:second_school) do
    create(
      :claims_school,
      name: "Hilltop Secondary",
      urn: "654321",
      address1: "2 Market Street",
      town: "Leeds",
      postcode: "LS1 1AA",
    )
  end

  let!(:claim_for_provider) do
    create(
      :claim,
      :submitted,
      status: :sampling_in_progress,
      provider:,
      school:,
      created_by: provider_user,
      submitted_by: provider_user,
      reference: "9000001",
      created_at: Time.zone.local(2026, 1, 10, 9, 0, 0),
    )
  end

  let!(:approved_claim_for_provider) do
    create(
      :claim,
      :submitted,
      status: :paid,
      provider:,
      school: second_school,
      created_by: provider_user,
      submitted_by: provider_user,
      reference: "9000003",
      created_at: Time.zone.local(2026, 1, 11, 9, 0, 0),
    )
  end

  let!(:unsupported_status_claim_for_provider) do
    create(
      :claim,
      :submitted,
      status: :submitted,
      provider:,
      school:,
      created_by: provider_user,
      submitted_by: provider_user,
      reference: "9000004",
      created_at: Time.zone.local(2026, 1, 12, 9, 0, 0),
    )
  end

  let!(:claim_for_other_provider) do
    create(:claim, :submitted, provider: other_provider, school:, reference: "9000002")
  end

  before do
    provider.users << provider_user
    other_provider.users << provider_user
    user_exists_in_dfe_sign_in(user: provider_user)
  end

  scenario "provider user selects an organisation and sees provider-scoped claims" do
    visit sign_in_path
    click_on "Sign in using DfE Sign In"

    expect(page).to have_current_path(claims_providers_path)
    click_on "North Star SCITT"

    expect(page).to have_current_path(claims_provider_claims_path(provider))
    expect(page).to have_content("Claims")
    expect(page).to have_content("Riverbank Primary")
    expect(page).to have_content("Hilltop Secondary")
    expect(page).to have_content("Claim reference: #{claim_for_provider.reference}")
    expect(page).to have_content("Claim reference: #{approved_claim_for_provider.reference}")
    expect(page).to have_no_content("Claim reference: #{claim_for_other_provider.reference}")
    expect(page).to have_no_content("Claim reference: #{unsupported_status_claim_for_provider.reference}")
    expect(page).to have_link("Change organisation", href: claims_providers_path)

    check "Riverbank Primary"
    click_on "Apply filters"

    expect(page).to have_current_path(
      claims_provider_claims_path(provider, params: { claims_providers_claims_filter_form: { school_ids: [school.id] } }),
      ignore_query: false,
    )
    expect(page).to have_content("Claim reference: #{claim_for_provider.reference}")
    expect(page).to have_no_content("Claim reference: #{approved_claim_for_provider.reference}")

    click_on "Clear filters"

    expect(page).to have_current_path(claims_provider_claims_path(provider))

    click_on "Riverbank Primary"

    expect(page).to have_current_path(claims_provider_claim_path(provider, claim_for_provider))
    expect(page).to have_content("Claim reference #{claim_for_provider.reference}")
    expect(page).to have_content("Submitted")
    expect(page).to have_content("Mentors")
    expect(page).to have_link("Approve claim")
    expect(page).to have_link("Amend claim")
  end
end
