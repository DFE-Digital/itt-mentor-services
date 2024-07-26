module Placements
  module Placements
    class NotifyProvider
      class Assign < NotifyProvider
        private

        def notify_users
          @provider.users.each do |user|
            UserMailer.with(service: :placements)
              .placement_provider_assigned_notification(
                user, @provider, @placement
              ).deliver_later
          end
        end
      end
    end
  end
end
