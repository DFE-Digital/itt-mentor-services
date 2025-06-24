module Placements
  module Placements
    module NotifySchool
      class CreatePlacements < ApplicationService
        def initialize(user:, school:, placements:)
          @user = user
          @school = school
          @placements = placements
        end

        def call
          notify_user
        end

        private

        def notify_user
          ::Placements::SchoolUserMailer
            .placement_information_added_notification(
              @user, @school, @placements
            ).deliver_later
        end
      end
    end
  end
end
