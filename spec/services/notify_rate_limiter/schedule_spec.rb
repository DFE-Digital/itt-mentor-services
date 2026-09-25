require "rails_helper"

describe NotifyRateLimiter::Schedule do
  subject(:schedule) { described_class.new(limit: 10) }

  describe "#reserve" do
    it "schedules emails in the same minute while they fit" do
      expect(schedule.reserve(4)).to eq(0.minutes)
      expect(schedule.reserve(6)).to eq(0.minutes)
      expect(schedule.reserve(1)).to eq(1.minute)
    end

    it "moves emails to the next minute when they do not fit" do
      expect(schedule.reserve(8)).to eq(0.minutes)
      expect(schedule.reserve(3)).to eq(1.minute)
      expect(schedule.reserve(7)).to eq(1.minute)
      expect(schedule.reserve(1)).to eq(2.minutes)
    end

    it "accounts for the extra minutes needed when emails exceed the limit" do
      expect(schedule.reserve(25)).to eq(0.minutes)
      expect(schedule.reserve(5)).to eq(2.minutes)
      expect(schedule.reserve(1)).to eq(3.minutes)
    end

    it "starts emails exceeding the limit in a fresh minute" do
      expect(schedule.reserve(2)).to eq(0.minutes)
      expect(schedule.reserve(15)).to eq(1.minute)
      expect(schedule.reserve(5)).to eq(2.minutes)
      expect(schedule.reserve(1)).to eq(3.minutes)
    end

    it "does not use up a minute when there are no emails" do
      expect(schedule.reserve(0)).to eq(0.minutes)
      expect(schedule.reserve(10)).to eq(0.minutes)
    end
  end
end
