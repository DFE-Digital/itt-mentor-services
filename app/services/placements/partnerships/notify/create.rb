module Placements
  module Partnerships
    class Notify
      class Create < Notify
        private

        def notify_users
          partner_organisation_users.each do |user|
            ::Placements::UserMailer
              .partnership_created_notification(
                user, @source_organisation, @partner_organisation
              ).deliver_later
          end
        end
      end
    end
  end
end
