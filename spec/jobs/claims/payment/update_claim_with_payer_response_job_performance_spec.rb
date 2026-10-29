require "rails_helper"

RSpec.describe Claims::Payment::UpdateClaimWithPayerResponseJob, type: :job do
  it "uses one claim row lock and one persisted-actor check per transition" do
    actor = create(:claims_support_user)
    claim = create(:claim, :payment_in_progress)
    response = create(:claims_payment_response, user: actor)
    queries = []
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      queries << payload.fetch(:sql) unless payload[:cached] || payload[:name] == "SCHEMA"
    end

    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record") do
      described_class.perform_now({ id: claim.id, status: "unpaid", unpaid_reason: "Check" }, response:)
    end

    expect(queries.grep(/FOR UPDATE/).length).to eq(1)
    expect(queries.grep(/SELECT 1 AS one FROM "users"/).length).to eq(1)
    expect(claim.reload.status).to eq("payment_information_requested")
    expect(claim.status_changes.order(:sequence).last).to have_attributes(actor:, source: response)
  end
end
