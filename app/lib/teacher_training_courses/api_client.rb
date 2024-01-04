require "net/http"

module TeacherTrainingCourses
  class ApiClient
    BASE_URL =
      "https://api.publish-teacher-training-courses.service.gov.uk/api/public/v1".freeze

    class << self
      def get(endpoint)
        request(method: :get, endpoint:)
      end

      def get_all_pages(endpoint)
        results = []
        is_last_page = false

        until is_last_page
          response = request(method: :get, endpoint:)
          results.concat response.fetch("data")

          if (next_page = response.dig("links", "next"))
            endpoint = next_page.delete_prefix(BASE_URL)
          else
            is_last_page = true
          end
        end

        results
      end

      private

      def request(method:, endpoint:)
        url = URI("#{BASE_URL}#{endpoint}")
        response = Net::HTTP.public_send(method, url)
        JSON.parse(response)
      end
    end
  end
end
