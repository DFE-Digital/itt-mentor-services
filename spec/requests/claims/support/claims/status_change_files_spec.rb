require "rails_helper"

RSpec.describe "Support claim status change files", service: :claims, type: :request do
  let(:claim) { create(:claim, :draft) }
  let(:payment) { create(:claims_payment, claims: []) }
  let(:source) { payment }
  let(:event) do
    Claims::ClaimStatusChange.create!(
      claim:, from_status: "submitted", to_status: "payment_in_progress",
      actor_kind: "unknown", imported: true, sequence: 1, source:
    )
  end

  def download_path(claim_id: claim.id, event_id: event.id)
    "/support/claims/#{claim_id}/status-changes/#{event_id}/file"
  end

  context "when signed in as support" do
    before { sign_in_as create(:claims_support_user) }

    it "downloads the event source's current file, not the previous version" do
      event
      payment.csv_file.attach(io: StringIO.new("latest,batch\n123,paid\n"), filename: "latest.csv", content_type: "text/csv")

      get download_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to eq("latest,batch\n123,paid\n")
      expect(response.headers["Content-Disposition"]).to include("latest.csv")
    end

    it "does not allow using another claim's event" do
      expect {
        get download_path(claim_id: create(:claim, :draft).id)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow an unknown event" do
      expect {
        get download_path(event_id: SecureRandom.uuid)
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "returns not found when the attachment is missing" do
      event
      payment.csv_file.purge

      get download_path

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Latest batch CSV is unavailable")
    end

    context "without a source" do
      let(:source) { nil }

      it "returns not found" do
        get download_path

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when the source has no file attachment" do
      let(:source) { claim }

      it "returns not found" do
        get download_path

        expect(response).to have_http_status(:not_found)
      end
    end

    it "returns not found when the stored file is unavailable" do
      event
      payment.csv_file.blob.service.delete(payment.csv_file.blob.key)

      get download_path

      expect(response).to have_http_status(:not_found)
    end

    context "with a payment response source" do
      let(:source) { create(:claims_payment_response) }

      it "downloads the response file" do
        get download_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(source.csv_file.download)
      end
    end

    context "with a clawback source" do
      let(:source) { create(:clawback, claims: []) }

      it "downloads the clawback file" do
        get download_path

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(source.csv_file.download)
      end
    end

    context "with a provider-specific sampling source" do
      let(:source) { create(:provider_sampling, :with_csv_file) }

      it "downloads only this event's provider file despite other source parameters" do
        other_source = create(:provider_sampling, :with_csv_file)
        other_source.csv_file.attach(io: StringIO.new("another,provider\n"), filename: "other.csv", content_type: "text/csv")

        get download_path, params: { source_id: other_source.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(source.csv_file.download)
        expect(response.body).not_to include("another,provider")
      end
    end
  end

  %i[claims_user claims_provider_user].each do |factory|
    context "when signed in as a #{factory}" do
      before { sign_in_as create(factory) }

      it "denies file access" do
        get download_path

        expect(response).to redirect_to(sign_in_path)
      end
    end
  end

  it "requires sign in" do
    get download_path

    expect(response).to redirect_to(sign_in_path)
  end
end
