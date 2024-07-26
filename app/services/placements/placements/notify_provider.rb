module Placements
  module Placements
    class NotifyProvider
      include ServicePattern

      def initialize(provider:, placement:)
        @provider = provider
        @placement = placement
      end

      def call
        return unless @provider.placements_service?

        notify_users
      end

      private

      def notify_users
        raise NoMethodError, "#notify_users must be implemented"
      end
    end
  end
end
