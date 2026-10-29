require "rails_helper"

RSpec.describe Claims::ClaimStatusChangesQuery do
  subject(:events) { described_class.call(claim:) }

  let(:claim) { create(:claim, :draft) }

  it "orders this claim's historical and live transitions by event time, with unknown dates last" do
    unknown = event(claim:, sequence: 1, occurred_at: nil)
    later = event(claim:, sequence: 2, occurred_at: 1.day.ago)
    earlier = event(claim:, sequence: 3, occurred_at: 2.days.ago)
    event(claim: create(:claim, :draft), sequence: 1, occurred_at: 1.day.ago)

    expect(events).to eq([earlier, later, unknown])
  end

  it "uses sequence to break ties between identical or unknown timestamps" do
    time = 1.day.ago
    second = event(claim:, sequence: 2, occurred_at: time)
    first = event(claim:, sequence: 1, occurred_at: time)
    unknown_second = event(claim:, sequence: 4, occurred_at: nil)
    unknown_first = event(claim:, sequence: 3, occurred_at: nil)

    expect(events).to eq([first, second, unknown_first, unknown_second])
  end

  private

  def event(**attributes)
    Claims::ClaimStatusChange.create!(
      from_status: "submitted", to_status: "paid", actor_kind: "unknown", imported: true, **attributes,
    )
  end
end
