require "rails_helper"

RSpec.describe "Support claim legacy history", service: :claims, type: :request do
  let(:claim) { create(:claim, :draft) }
  let(:path) { "/support/claims/#{claim.id}/legacy-history" }

  context "when signed in as support" do
    before { sign_in_as create(:claims_support_user) }

    it "shows exact original audit changes and metadata, associated mentor evidence and activities" do
      claim.update!(zendesk_url: "https://example.com/12345")
      audit = claim.audits.last
      audit.update_columns(comment: "Original retained comment", request_uuid: "original-request", remote_address: "192.0.2.1")
      training = create(:mentor_training, claim:, hours_completed: 6)
      activity = create(:claim_activity, action: :rejected_by_payer, record: claim)
      other = create(:claim, :draft, zendesk_url: "https://example.com/unrelated-secret")

      get path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Original retained comment", "original-request", "192.0.2.1", "12345")
      expect(response.body).to include(ERB::Util.html_escape(audit.audited_changes.to_json))
      expect(response.body).to include(training.audits.last.id.to_s, "hours_completed")
      expect(response.body).to include(claims_support_claims_claim_activity_path(activity))
      expect(response.body).not_to include(other.zendesk_url)
    end

    it "scopes the claim lookup" do
      expect {
        get "/support/claims/#{SecureRandom.uuid}/legacy-history"
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "shows explicit empty archive sections" do
      allow(Claims::ClaimLegacyAuditsQuery).to receive(:call).and_return(Audited::Audit.none)

      get path

      expect(response.body).to include("There are no legacy audits.", "There are no operational activities.")
    end

    it "escapes retained raw evidence rather than executing markup" do
      claim.audits.last.update_columns(comment: "<script>alert('legacy')</script>")

      get path

      expect(response.body).to include("\\u003cscript\\u003e")
      expect(response.body).not_to include("<script>alert('legacy')</script>")
    end

    it "paginates audits independently of operational activities" do
      26.times { |index| claim.update!(zendesk_url: "https://example.com/#{index}") }
      first_audit = claim.audits.reorder(:created_at, :id).first
      last_audit = claim.audits.reorder(:created_at, :id).last

      get path, params: { audit_page: 2 }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Audit #{last_audit.id}:")
      expect(response.body).not_to include("Audit #{first_audit.id}:")
      expect(response.body).to include("There are no operational activities.")
    end

    it "includes response activities only through an explicit event source association" do
      payment_response = create(:claims_payment_response)
      activity = create(:claim_activity, action: :payment_response_uploaded, record: payment_response)
      Claims::ClaimStatusChange.create!(
        claim:, source: payment_response, from_status: "submitted", to_status: "paid",
        actor_kind: "unknown", sequence: 1, imported: true
      )

      get path

      expect(response.body).to include(claims_support_claims_claim_activity_path(activity))
      expect(response.body).to include(payment_response.id)
    end
  end

  %i[claims_user claims_provider_user].each do |factory|
    it "denies archive access for a #{factory}" do
      sign_in_as create(factory)

      get path

      expect(response).to redirect_to(sign_in_path)
    end
  end

  it "requires sign in" do
    get path

    expect(response).to redirect_to(sign_in_path)
  end
end
