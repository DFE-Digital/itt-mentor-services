module PublishTeacherTraining
  module Provider
    class Api < ApplicationService
      def initialize(link: nil)
        @link = link.presence || all_providers_url
      end

      attr_reader :link

      def call
        response = HTTParty.get(link)
        JSON.parse(response.to_s)
      end

      private

      def all_providers_url
        "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/current/providers"
      end
    end
  end
end
