module PublishTeacherTraining
  module Course
    class Api < ApplicationService
      def initialize(year:)
        @year = year
      end

      def call
        response = HTTParty.get(all_courses_url,
                                query: query_params)
        JSON.parse(response.body)
      end

      private

      def query_params
        {
          year: @year,
        }
      end

      def all_courses_url
        "#{ENV["PUBLISH_BASE_URL"]}/api/public/v1/recruitment_cycles/#{@year}/courses?include=provider"
      end
    end
  end
end
