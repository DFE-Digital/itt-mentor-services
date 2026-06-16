class Claims::ProviderUser::CreateAndDeliverJob < ApplicationJob
  queue_as :default

  def perform(provider_id:, user_details:)
    provider = Claims::Provider.find(provider_id)
    return if provider.users.find_by(email: user_details[:email])

    user = Claims::ProviderUser.find_or_create_by!(email: user_details[:email]) do |u|
      u.first_name = user_details[:first_name]
      u.last_name = user_details[:last_name]
    end

    user.user_memberships.create!(organisation: provider)

    User::Invite.call(user:, organisation: provider)
  end
end
