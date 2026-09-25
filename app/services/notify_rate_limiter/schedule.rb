# Shares one rate limit across many NotifyRateLimiter calls, so a job that
# emails the users of many records sends no more than `limit` emails per
# `interval` in total, rather than per record.
class NotifyRateLimiter::Schedule
  attr_reader :limit, :interval

  def initialize(limit: 100, interval: 1.minute)
    @limit = limit
    @interval = interval
    @wait_time = 0.minutes
    @used = 0
  end

  # Reserves room for `count` emails and returns the initial_wait_time to pass
  # to NotifyRateLimiter (with batch_size: limit and interval: interval).
  def reserve(count)
    if used.positive? && used + count > limit
      @wait_time += interval
      @used = 0
    end

    start_time = wait_time
    total = used + count
    extra_intervals = [total - 1, 0].max / limit
    @wait_time += extra_intervals * interval
    @used = total - (extra_intervals * limit)

    start_time
  end

  private

  attr_reader :wait_time, :used
end
