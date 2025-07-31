class Claims::Claim::InvalidProviderNotification < ApplicationService
  def call
    created_by_ids = Claims::Claim.where(status: :invalid_provider).select(:created_by_id)
    users_to_notify = Claims::User.where(id: created_by_ids).distinct

    return if users_to_notify.empty?

    NotifyRateLimiter.call(
      collection: users_to_notify,
      mailer: "Claims::UserMailer",
      mailer_method: :claims_assigned_to_invalid_provider,
    )
  end
end
