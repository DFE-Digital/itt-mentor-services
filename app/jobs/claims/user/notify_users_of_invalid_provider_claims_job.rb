class Claims::User::NotifyUsersOfInvalidProviderClaimsJob < ApplicationJob
  queue_as :default

  def perform
    if Claims::ClaimWindow.current.present?
      Claims::Claim::InvalidProviderNotification.call
    end
  end
end
