module Placements
  module Partnerships
    module Notify
      class Removal
        include ServicePattern

        def initialize(source_organisation:, partner_organisation:)
          @source_organisation = source_organisation
          @partner_organisation = partner_organisation
        end

        def call
          return unless @partner_organisation.placements_service?

          @partner_organisation.users.each do |user|
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
