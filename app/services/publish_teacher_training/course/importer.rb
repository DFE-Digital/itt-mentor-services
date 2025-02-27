module PublishTeacherTraining
  module Course
    class Importer < ApplicationService
      def call
        @records = []

        fetch_course_attributes(year: "2023")

        @records.each do |record|
          subject = ::Subject.find_by(code: record[:subject_codes])

          if subject.present?
            Placements::Course.find_or_create_by!(code: record[:code]) do |course|
              course.uuid = record[:uuid]
              course.name = record[:name]
              course.subject_codes = record[:subject_codes]
              course.provider_id = record[:provider_id]
              course.subject_id = subject.id
            end
          else
            Rails.logger.info "Subject #{record[:subject_codes]} not found"
          end
        end
      end

      private

      # named param to add when paginating - link: nil
      def fetch_course_attributes(year:)
        courses = ::PublishTeacherTraining::Course::Api.call(year:)
        courses.fetch("data").each do |course|
          course_attributes = course["attributes"]
          provider_id = course.dig("relationships", "provider", "data", "id")
          # validation that state is published?

          @records << {
            uuid: course_attributes["uuid"],
            code: course_attributes["code"],
            name: course_attributes["name"],
            provider_id:,
            subject_codes: course_attributes["subject_codes"],
          }
        end
        # if courses.dig("links", "next").present?
        #   fetch_course_attributes(year:, link: courses.dig("links", "next"))
        # end
      end
    end
    # In a job, import courses first then grab trainees.
  end
end
