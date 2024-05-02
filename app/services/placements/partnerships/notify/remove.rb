module Placements
  module Partnerships
    class Notify
      class Remove < Notify
        private

        def notify_users
          partner_organisation_users.each do |user|
            UserMailer.with(service: :placements)
              .partnership_destroyed_notification(
                user, @source_organisation, @partner_organisation
              ).deliver_later
          end
        end
      end
    end
  end
end
