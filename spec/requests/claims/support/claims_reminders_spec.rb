require "rails_helper"

RSpec.describe "Claims Reminders", type: :request do
  describe "POST /claims/support/claims_reminders/send_schools_not_submitted_claims" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:next_claim_window) { create(:claim_window, :upcoming) }
    let(:claims_school) { build(:claims_school, eligible_claim_windows: [claim_window]) }
    let!(:claims_user) { create(:claims_user, schools: [claims_school]) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      next_claim_window
      sign_in_as support_user
      mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(Claims::UserMailer).to receive(:claims_have_not_been_submitted).and_return(mailer_double)
    end

    it "sends reminders to users and redirects with a flash message" do
      post send_schools_not_submitted_claims_claims_support_claims_reminders_path

      expect(Claims::UserMailer).to have_received(:claims_have_not_been_submitted).at_least(:once).with(claims_user)
    end
  end

  describe "POST /claims/support/claims_reminders/send_providers_not_submitted_claims" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:email_address) { build(:provider_email_address) }
    let(:current_claim) { build(:claim, claim_window: claim_window) }
    let(:previous_claim) { build(:claim, claim_window: build(:claim_window, :historic)) }
    let!(:provider_with_no_claims) { create(:claims_provider, name: "Test Provider", accredited: true) }
    let!(:provider_with_claims_in_current_window) { create(:claims_provider, name: "Provider with Claims", claims: [current_claim], accredited: true) }
    let!(:provider_with_claims_in_previous_window) { create(:claims_provider, name: "Provider with Previous Claims", claims: [previous_claim], accredited: true) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      sign_in_as support_user
      mailer_double = instance_double(ActionMailer::MessageDelivery, deliver_later: true)
      allow(Claims::ProviderMailer).to receive(:claims_have_not_been_submitted).and_return(mailer_double)
    end

    it "sends reminders to providers and redirects with a flash message" do
      post send_providers_not_submitted_claims_claims_support_claims_reminders_path

      expect(Claims::ProviderMailer).to have_received(:claims_have_not_been_submitted).once.with(provider_name: provider_with_no_claims.name, email_address: provider_with_no_claims.email_addresses.first)
      expect(Claims::ProviderMailer).not_to have_received(:claims_have_not_been_submitted).with(provider_name: provider_with_claims_in_current_window.name, email_address: provider_with_claims_in_current_window.email_addresses.first)
      expect(Claims::ProviderMailer).to have_received(:claims_have_not_been_submitted).with(provider_name: provider_with_claims_in_previous_window.name, email_address: provider_with_claims_in_previous_window.email_addresses.first)
    end
  end
end
