require "rails_helper"

RSpec.describe Claims::RemoveInternalDraftClaimsJob, type: :job do
  describe "#perform" do
    it "calls the Claims::Claim::RemoveInternalDrafts service" do
      expect(Audited.audit_class).to receive(:as_user).with("System").and_yield
      expect(Claims::Claim::RemoveInternalDrafts).to receive(:call)
      described_class.perform_now
    end

    it "enqueues the job in the default queue" do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue("default")
    end
  end
end
