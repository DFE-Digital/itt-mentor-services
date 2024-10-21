module Placements
  module Placements
    class NotifyProvider
      class Remove < NotifyProvider
        private

        def notify_users
          @provider.users.each do |user|
            ::Placements::ProviderUserMailer
              .placement_provider_removed_notification(
                user, @provider, @placement
              ).deliver_later
          end
        end
      end
    end
  end
end
