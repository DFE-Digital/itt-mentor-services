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

    context "when there is no current claim window" do
      let(:previous_claim_window) { create(:claim_window, :historic) }
      let(:not_signed_in_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: nil) }
      let(:claims_school) { build(:claims_school, eligibilities: [build(:eligibility, academic_year: previous_claim_window.academic_year)]) }

      before do
        claim_window.update!(ends_on: 1.day.ago)
        not_signed_in_user
      end

      it "sends reminders for the previous claim window" do
        post send_schools_not_signed_in_claims_support_claims_reminders_path
        expect(NotifyRateLimiter).to have_received(:call).with(collection: [not_signed_in_user], mailer: "Claims::UserMailer", mailer_method: :your_school_has_not_signed_in)
      end
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

  describe "POST /claims/support/claims_reminders/send_your_school_has_signed_in_but_not_claimed" do
    let(:claim_window) { create(:claim_window, :current) }
    let(:eligibility) { build(:eligibility, academic_year: claim_window.academic_year) }
    let(:claims_school) { build(:claims_school, eligibilities: [eligibility]) }
    let(:school_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: 1.day.ago) }
    let(:support_user) { create(:claims_support_user) }

    before do
      claim_window
      eligibility
      claims_school
      school_user
      service_double = instance_double(NotifyRateLimiter)
      allow(NotifyRateLimiter).to receive(:call).and_return(service_double)

      sign_in_as support_user
    end

    context "when the school has not made a claim" do
      it "sends reminders to users who have signed in but not claimed and redirects with a flash message" do
        post send_your_school_has_signed_in_but_not_claimed_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).to have_received(:call).with(collection: [school_user], mailer: "Claims::UserMailer", mailer_method: :your_school_has_signed_in_but_not_claimed)
      end
    end

    context "when the school has made a claim" do
      let(:claim) { create(:claim, claim_window:, school: claims_school) }

      before { claim }

      it "does not send reminders to users for the school" do
        post send_your_school_has_signed_in_but_not_claimed_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end

    context "when the school has made a claim in a previous window" do
      let(:previous_claim) { build(:claim, claim_window: build(:claim_window, :historic), school: claims_school) }

      before { previous_claim }

      it "sends reminders to users who have signed in but not claimed and redirects with a flash message" do
        post send_your_school_has_signed_in_but_not_claimed_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).to have_received(:call).with(collection: [school_user], mailer: "Claims::UserMailer", mailer_method: :your_school_has_signed_in_but_not_claimed)
      end
    end

    context "when users have not signed in to the school" do
      let(:school_user) { create(:claims_user, schools: [claims_school], last_signed_in_at: nil) }

      it "does not send reminders" do
        post send_your_school_has_signed_in_but_not_claimed_claims_support_claims_reminders_path

        expect(NotifyRateLimiter).not_to have_received(:call)
      end
    end
  end
end
