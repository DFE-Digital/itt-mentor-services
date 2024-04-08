module Placements
  module Partnerships
    module Notify
      class Creation
        include ServicePattern

        def initialize(source_organisation:, partner_organisation:)
          @source_organisation = source_organisation
          @partner_organisation = partner_organisation
        end

        def call
          @partner_organisation.users.each do |user|
            UserMailer.with(service: :placements)
              .partnership_created_notification(
                user, @source_organisation, @partner_organisation
              ).deliver_later
          end
        end
      end
    end
  end
end
