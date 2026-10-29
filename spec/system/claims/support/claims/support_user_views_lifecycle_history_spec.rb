require "rails_helper"

RSpec.describe "Support user views claim lifecycle history and legacy evidence", service: :claims, type: :system do
  after { Flipper.disable(:claim_status_history) }

  scenario do
    given_a_claim_has_transitions_and_legacy_evidence
    and_given_lifecycle_history_is_enabled
    and_given_i_am_signed_in_as_a_claims_support_user

    when_i_view_the_claim_history
    then_i_see_only_status_transitions_with_honest_attribution

    when_i_open_the_legacy_archive
    then_i_see_original_non_status_evidence
  end

  scenario "all four claim detail surfaces share the lifecycle timeline" do
    given_a_claim_has_transitions_and_legacy_evidence
    and_given_lifecycle_history_is_enabled
    and_given_i_am_signed_in_as_a_claims_support_user

    when_i_view_each_support_claim_surface
    then_every_surface_has_the_same_history
  end

  scenario "a claim without transitions has explicit empty history" do
    given_a_claim_without_transitions
    and_given_lifecycle_history_is_enabled
    and_given_i_am_signed_in_as_a_claims_support_user

    when_i_view_the_claim_history
    then_i_see_an_empty_history_and_archive_link
  end

  scenario "all four surfaces retain operational history before the reconciled cutover" do
    given_a_claim_has_transitions_and_legacy_evidence
    and_given_lifecycle_history_is_disabled
    and_given_i_am_signed_in_as_a_claims_support_user

    when_i_view_each_support_claim_surface
    then_every_surface_keeps_the_operational_history
  end

  private

  def given_a_claim_has_transitions_and_legacy_evidence
    @claim = create(:claim, :submitted, school: create(:claims_school, name: "Shelbyville Elementary", region: regions(:inner_london)))
    @claim.update!(zendesk_url: "https://example.com/12345")
    @payment = create(:claims_payment, claims: [])
    @activity = create(:claim_activity, action: :rejected_by_payer, record: @claim)
    event(sequence: 1, from_status: "draft", to_status: "submitted", actor_kind: "user", actor_name: "Anne Wilson", source: @payment)
    event(sequence: 2, from_status: "submitted", to_status: "paid", actor_kind: "system", system_operation: "Reconcile payment response")
    event(sequence: 3, from_status: "paid", to_status: "submitted", actor_kind: "unknown", occurred_at: nil)
    event(sequence: 4, from_status: nil, to_status: "paid", actor_kind: "user", actor: create(:claims_provider_user, first_name: "Patricia", last_name: "Jones"))
    event(sequence: 5, from_status: "submitted", to_status: "paid", actor_kind: "user")
    event(sequence: 6, from_status: "submitted", to_status: "paid", actor_kind: "system")
  end

  def event(**attributes)
    attributes[:sequence] += 10
    Claims::ClaimStatusChange.create!(claim: @claim, imported: true, occurred_at: Time.zone.parse("2024-06-10 12:00"), **attributes)
  end

  def and_given_lifecycle_history_is_enabled
    Flipper.enable(:claim_status_history)
  end

  def and_given_lifecycle_history_is_disabled
    Flipper.disable(:claim_status_history)
  end

  def and_given_i_am_signed_in_as_a_claims_support_user
    given_i_am_signed_in_as_a_claims_support_user
  end

  def when_i_view_the_claim_history
    visit claims_support_claim_path(@claim)
  end

  def then_i_see_only_status_transitions_with_honest_attribution(title_prefix = "Shelbyville Elementary - Claim")
    expect(page).to have_title("#{title_prefix} #{@claim.reference} - Claim funding for mentor training - GOV.UK")
    within ".app-timeline" do
      expect(page).to have_content("Draft → Submitted")
      expect(page).to have_content("Anne Wilson")
      expect(page).to have_content("Reconcile payment response")
      expect(page).to have_content("System operation: Historical operation unknown")
      expect(page).to have_content("Historical actor unknown")
      expect(page).to have_content("Historical date unknown")
      expect(page).to have_content("Previous status unknown → Paid")
      expect(page).to have_content("Patricia Jones")
      expect(page).to have_link("Latest batch CSV")
      expect(page).to have_content("Latest batch CSV is unavailable")
      expect(page).not_to have_link("View details")
    end
  end

  def when_i_open_the_legacy_archive
    click_on "Legacy audit archive"
  end

  def then_i_see_original_non_status_evidence
    expect(page).to have_title("Legacy audit archive - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK")
    expect(page).to have_h1("Legacy audit archive")
    expect(page).to have_content("zendesk_url")
    expect(page).to have_content("12345")
    expect(page).to have_link("View activity details")
    expect(page).to have_link("Back", href: claims_support_claim_path(@claim))
  end

  def when_i_view_each_support_claim_surface
    @surfaces = [
      [claims_support_claim_path(@claim), "Shelbyville Elementary - Claim"],
      [claims_support_claims_payments_claim_path(@claim), "Shelbyville Elementary - Claim"],
      [claims_support_claims_sampling_path(@claim), "Shelbyville Elementary - Auditing - Claim"],
      [claims_support_claims_clawback_path(@claim), "Clawbacks - Shelbyville Elementary - Claim"],
    ]
  end

  def then_every_surface_has_the_same_history
    @surfaces.each do |path, title_prefix|
      visit path
      then_i_see_only_status_transitions_with_honest_attribution(title_prefix)
      expect(page).to have_link("Legacy audit archive", href: "/support/claims/#{@claim.id}/legacy-history")
    end
  end

  def given_a_claim_without_transitions
    @claim = create(:claim, :submitted, school: create(:claims_school, region: regions(:inner_london)))
    allow(Claims::ClaimStatusChangesQuery).to receive(:call).and_return(Claims::ClaimStatusChange.none)
  end

  def then_i_see_an_empty_history_and_archive_link
    expect(page).to have_title("#{@claim.school_name} - Claim #{@claim.reference} - Claim funding for mentor training - GOV.UK")
    expect(page).to have_content("There are no status changes.")
    expect(page).to have_link("Legacy audit archive")
  end

  def then_every_surface_keeps_the_operational_history
    expect(Claims::ClaimStatusChangesQuery).not_to receive(:call)
    @surfaces.each do |path, title_prefix|
      visit path
      expect(page).to have_title("#{title_prefix} #{@claim.reference} - Claim funding for mentor training - GOV.UK")
      expect(page).to have_link("View details", href: claims_support_claims_claim_activity_path(@activity))
      expect(page).not_to have_link("Legacy audit archive")
      expect(page).not_to have_link("Latest batch CSV")
    end
  end
end
