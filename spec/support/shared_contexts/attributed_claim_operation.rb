RSpec.shared_context "with an attributed claim operation" do
  let(:audit_actor) { create(:claims_support_user) }

  before { Claims::AuditContext.actor = audit_actor }
  after { Claims::AuditContext.reset }
end
