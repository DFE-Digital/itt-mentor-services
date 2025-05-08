module Placements
  module Placements
    module NotifySchool
      class RemoveProvider < ApplicationService
        def initialize(school:, provider:, placement:)
          @school = school
          @provider = provider
          @placement = placement
        end

        def call
          notify_users
        end

        private

        def notify_users
          @school.users.each do |user|
            ::Placements::SchoolUserMailer
              .placement_provider_removed_notification(
                user, @school, @provider, @placement
              ).deliver_later
          end
        end
      end
    end
  end
end
