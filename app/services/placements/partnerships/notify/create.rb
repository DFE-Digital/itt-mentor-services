module Placements
  module Partnerships
    class Notify
      class Create < Notify
        private

        def notify_users
          partner_organisation_users.each do |user|
            mailer_class
              .partnership_created_notification(
                user, @source_organisation, @partner_organisation
              ).deliver_later
          end
        end

        def mailer_class
          @source_organisation.is_a?(::School) ? ::Placements::ProviderUserMailer : ::Placements::SchoolUserMailer
        end
      end
    end
  end
end
