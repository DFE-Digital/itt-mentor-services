module Placements
  module Placements
    class NotifyProvider
      class Assign < NotifyProvider
        private

        def notify_users
          @provider.users.each do |user|
            ::Placements::ProviderUserMailer
              .placement_provider_assigned_notification(
                user, @provider, @placement
              ).deliver_later
          end
        end
      end
    end
  end
end
