module PublishTeacherTraining
  module Course
    class Importer < ApplicationService
      def call
        @records = []

        fetch_course_attributes(year: "2023")

        @records.each do |record|
          Placements::Course.find_or_create_by(code: record[:code]) do |course|
            course.subject_codes = record[:subject_codes]
          end
        end
      end

      private

      def fetch_course_attributes(year:, link: nil)
        courses = ::PublishTeacherTraining::Course::Api.call(year:)
        courses.fetch("data").each do |course|
          course_attributes = course["attributes"]

          @records << {
            code: course_attributes["code"],
            subject_codes: course_attributes["subject_codes"],
          }
        end

        # if courses.dig("links", "next").present?
        #   fetch_course_attributes(year:, link: courses.dig("links", "next"))
        # end
      end
    end
  end
end
