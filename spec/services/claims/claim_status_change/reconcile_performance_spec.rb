require "rails_helper"

RSpec.describe Claims::ClaimStatusChange::Reconcile do
  it "checks current claim states with a fixed query count within a database batch" do
    claims = create_list(:claim, 3, :submitted)
    service = described_class.send(:new)
    first_count = query_count { service.send(:reconcile_current_state, Hash.new(0)) }
    create_list(:claim, 3, :paid)
    second_count = query_count { service.send(:reconcile_current_state, Hash.new(0)) }

    expect(second_count).to eq(first_count)
    expect(service.send(:reconcile_current_state, Hash.new(0))[:checked]).to eq(claims.length + 3)
  end

  def query_count(&block)
    count = 0
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      count += 1 unless payload[:cached] || payload[:name] == "SCHEMA"
    end
    ActiveSupport::Notifications.subscribed(subscriber, "sql.active_record", &block)
    count
  end
end
