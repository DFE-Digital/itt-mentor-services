class Claims::Claim::InvalidProviderNotification < ApplicationService
  def call
    created_by_ids = Claims::Claim.where(status: :invalid_provider).select(:created_by_id)
    users_to_notify = Claims::User.where(id: created_by_ids).distinct

    return if users_to_notify.empty?

    time_to_wait = 0.minutes
    users_to_notify.find_in_batches(batch_size: 100) do |users_batch|
      users_batch.each do |user|
        claims = Claims::Claim.where(created_by: user, status: :invalid_provider)
        Claims::UserMailer.claims_assigned_to_invalid_provider(user.id, claims.ids).deliver_later(wait: time_to_wait)
        time_to_wait += 1.minute
      end
    end
  end
end
