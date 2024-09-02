module PublishTeacherTraining
  module Subject
    class Api < ApplicationService
      def call
        response = HTTParty.get(link)
        JSON.parse(response.to_s)
      end

      private

      def link
        "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/subject_areas?include=subjects"
      end
    end
  end
end
