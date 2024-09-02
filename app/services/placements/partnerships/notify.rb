module Placements
  module Partnerships
    class Notify < ApplicationService
      def initialize(source_organisation:, partner_organisation:)
        @source_organisation = source_organisation
        @partner_organisation = partner_organisation
      end

      def call
        return unless @partner_organisation.placements_service?

        notify_users
      end

      private

      def partner_organisation_users
        @partner_organisation.users.where(type: "Placements::User")
      end

      def notify_users
        raise NoMethodError, "#notify_users must be implemented"
      end
    end
  end
end
