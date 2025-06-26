module Placements
  module Placements
    module NotifySchool
      class CreatePlacements < ApplicationService
        def initialize(user:, school:, placements:, academic_year:)
          @user = user
          @school = school
          @placements = placements
          @academic_year = academic_year
        end

        def call
          notify_user
        end

        private

        def notify_user
          ::Placements::SchoolUserMailer
            .placement_information_added_notification(
              @user, @school, @placements, @academic_year
            ).deliver_later
        end
      end
    end
  end
end
