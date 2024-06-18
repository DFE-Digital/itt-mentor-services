require "rails_helper"

RSpec.describe TrimExpiredSessionsJob, type: :job do
  def create_session(attributes)
    ActiveRecord::SessionStore::Session.create!(
      session_id: SecureRandom.uuid,
      data: "Some very important session data",
      **attributes,
    )
  end

  # Freeze time to avoid drift during the test – so we can be sure
  # "exactly 2 hours old" does not become "more than 2 hours old"
  before { Timecop.freeze }
  after { Timecop.return }

  it "deletes sessions which haven't been active in more than 2 hours" do
    two_weeks_old = create_session(updated_at: 2.weeks.ago)
    two_days_old = create_session(updated_at: 2.days.ago)
    three_hours_old = create_session(updated_at: 3.hours.ago)
    two_hours_old = create_session(updated_at: 2.hours.ago)
    one_hour_old = create_session(updated_at: 1.hour.ago)
    twenty_minutes_old = create_session(updated_at: 20.minutes.ago)

    described_class.perform_now

    expect_deleted = [two_weeks_old, two_days_old, three_hours_old]
    expect_remaining = [two_hours_old, one_hour_old, twenty_minutes_old]

    expect(ActiveRecord::SessionStore::Session.where(id: expect_deleted.map(&:id))).to be_empty
    expect(ActiveRecord::SessionStore::Session.all).to match_array(expect_remaining)
  end
end
