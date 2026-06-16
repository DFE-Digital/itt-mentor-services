class Claims::ProviderUser::CreateCollectionJob < ApplicationJob
  queue_as :default

  MAX_COUNT = 500
  MAX_CREATE_AND_DELIVER_PER_MINUTE = 100

  def perform(provider_user_details:)
    if provider_user_details.count > MAX_COUNT
      provider_user_details.each_slice(MAX_COUNT) do |batch|
        Claims::ProviderUser::CreateCollectionJob.perform_later(provider_user_details: batch)
      end
    else
      provider_user_details.each_with_index do |user_detail, index|
        provider = Claims::Provider.find(user_detail[:provider_id])
        existing_user = provider.users.find_by(email: user_detail[:email])
        next if existing_user.present?

        wait_time = (index / MAX_CREATE_AND_DELIVER_PER_MINUTE).minutes

        Claims::ProviderUser::CreateAndDeliverJob.set(wait: wait_time).perform_later(
          provider_id: provider.id,
          user_details: user_detail,
        )
      end
    end
  end
end
