class Claims::School::OnboardSchoolsJob < ApplicationJob
  queue_as :default
  MAX_EMAILS_PER_MINUTE = 100
  RATE_LIMIT_INTERVAL = 1.minute

  def perform(school_ids:, claim_window_id: nil)
    @claim_window_id = claim_window_id
    wait_time = 0.minutes
    remaining_capacity = MAX_EMAILS_PER_MINUTE

    school_ids.each do |school_id|
      school = School.find(school_id)
      school.update!(claims_service: true)

      Claims::Eligibility.find_or_create_by!(
        school:,
        academic_year:,
      )

      user_count = school.users.count
      next if user_count.zero?

      wait_time, remaining_capacity = schedule_eligibility_email(
        school:,
        user_count:,
        wait_time:,
        remaining_capacity:,
      )
    end
  end

  private

  attr_reader :claim_window_id

  def schedule_eligibility_email(school:, user_count:, wait_time:, remaining_capacity:)
    if user_count > MAX_EMAILS_PER_MINUTE
      if remaining_capacity < MAX_EMAILS_PER_MINUTE
        wait_time += RATE_LIMIT_INTERVAL
      end

      NotifyRateLimiter.call(
        collection: school.users,
        mailer: "Claims::UserMailer",
        mailer_method: :your_school_is_eligible_to_claim,
        mailer_args: [school],
        batch_size: MAX_EMAILS_PER_MINUTE,
        interval: RATE_LIMIT_INTERVAL,
        initial_wait_time: wait_time,
      )

      wait_time += emails_batches_required(user_count) * RATE_LIMIT_INTERVAL

      return [wait_time, MAX_EMAILS_PER_MINUTE]
    end

    if user_count > remaining_capacity
      wait_time += RATE_LIMIT_INTERVAL
      remaining_capacity = MAX_EMAILS_PER_MINUTE
    end

    NotifyRateLimiter.call(
      collection: school.users,
      mailer: "Claims::UserMailer",
      mailer_method: :your_school_is_eligible_to_claim,
      mailer_args: [school],
      batch_size: MAX_EMAILS_PER_MINUTE,
      interval: RATE_LIMIT_INTERVAL,
      initial_wait_time: wait_time,
    )

    remaining_capacity -= user_count

    if remaining_capacity.zero?
      [wait_time + RATE_LIMIT_INTERVAL, MAX_EMAILS_PER_MINUTE]
    else
      [wait_time, remaining_capacity]
    end
  end

  def emails_batches_required(total_emails)
    (total_emails.to_f / MAX_EMAILS_PER_MINUTE).ceil
  end

  def academic_year
    if claim_window_id
      Claims::ClaimWindow.find(claim_window_id).academic_year
    else
      Claims::ClaimWindow.current.academic_year
    end
  end
end
