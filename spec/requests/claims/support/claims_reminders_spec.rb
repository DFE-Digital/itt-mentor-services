require "rails_helper"

RSpec.describe "Claims Reminders", type: :request do
  include ActiveJob::TestHelper

  around do |example|
    perform_enqueued_jobs { example.run }
  end

  describe "POST /claims/support/claims_reminders/send_schools_not_submitted_claims" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:next_claim_window) { create(:claim_window, :upcoming) }
    let(:eligibility) { build(:eligibility, academic_year: claim_window.academic_year) }
    let(:claims_school) { build(:claims_school, eligibilities: [eligibility]) }
    let(:claims_user) { create(:claims_user, schools: [claims_school]) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      next_claim_window
      claims_user
      sign_in_as support_user
      service_double = instance_double(NotifyRateLimiter)
      allow(NotifyRateLimiter).to receive(:call).and_return(service_double)
    end

    it "sends reminders to users and redirects with a flash message" do
      post send_schools_not_submitted_claims_claims_support_claims_reminders_path

      expect(NotifyRateLimiter).to have_received(:call).exactly(:once)
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

      expect(Claims::ProviderMailer).to have_received(:claims_have_not_been_submitted).once.with(provider_with_no_claims.provider_email_addresses.first)
      expect(Claims::ProviderMailer).to have_received(:claims_have_not_been_submitted).with(provider_with_claims_in_previous_window.provider_email_addresses.first)

      expect(Claims::ProviderMailer).not_to have_received(:claims_have_not_been_submitted).with(provider_with_claims_in_current_window.provider_email_addresses.first)
    end
  end

  describe "POST /claims/support/claims_reminders/send_schools_not_signed_in" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:claims_school) { build(:claims_school, eligibilities: [build(:eligibility, academic_year: claim_window.academic_year)]) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      service_double = instance_double(NotifyRateLimiter)
      allow(NotifyRateLimiter).to receive(:call).and_return(service_double)

      sign_in_as support_user
    end

    context "when the school has no users who have signed in" do
      let(:not_signed_in_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: nil) }

      before { not_signed_in_user }

      it "sends reminders to users who have not signed in and redirects with a flash message" do
        post send_schools_not_signed_in_claims_support_claims_reminders_path
        expect(NotifyRateLimiter).to have_received(:call).with(collection: [not_signed_in_user], mailer: "Claims::UserMailer", mailer_method: :your_school_has_not_signed_in)
      end
    end

    context "when the school has signed in users" do
      let(:signed_in_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: 1.day.ago) }

      before { signed_in_user }

      it "does not send reminders to users for the school" do
        post send_schools_not_signed_in_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when the schools has users who have signed in and users who have not signed in" do
      let(:signed_in_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: 1.day.ago) }
      let(:not_signed_in_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: nil) }

      before do
        signed_in_user
        not_signed_in_user
      end

      it "does not send reminders" do
        post send_schools_not_signed_in_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end
  end
end
