module ApplyRegister
  module TraineeSubjects
    class Importer < ApplicationService
      def call
        @records = []

        fetch_application_attributes(year: "2025")

        @records.each do |record|
          Trainee.find_or_create_by(candidate_id: record[:candidate_id]) do |trainee|
            trainee.itt_course_code = record[:itt_course_code]
            trainee.study_mode = record[:study_mode]
            trainee.training_provider_code = record[:training_provider_code]
          end
        end
      end

      private

      def fetch_application_attributes(year:, changed_since: nil)
        applications = ::ApplyRegister::Api.call(year:, changed_since:)
        applications.fetch("data").each do |application_details|
          application_attributes = application_details["attributes"]

          @records << {
            candidate_id: application_attributes["candidate"]["id"],
            itt_course_code: application_attributes["course"]["course_code"],
            training_provider_code: application_attributes["course"]["training_provider_code"],
            study_mode: application_attributes["course"]["study_mode"],
          }
        end
      end

      def provider_by_code(code)
        ::Provider.find_by(code:)
      end

      def course_by_code; end
    end
  end
end
