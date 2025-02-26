module ApplyRegister
  module Trainees
    class Importer < ApplicationService
      def call
        @records = []
        @invalid_records = []

        fetch_application_attributes(year: "2023")

        if @invalid_records.any?
          Rails.logger.info "Invalid candidates - #{@invalid_records.inspect}"
        end

        @records.each do |record|
          course = Placements::Course.find_by(code: record[:itt_course_code])

          if course.present?
            Placements::Trainee.find_or_create_by!(candidate_id: record[:candidate_id]) do |trainee|
              trainee.itt_course_code = record[:itt_course_code]
              trainee.itt_course_uuid = record[:itt_course_uuid]
              trainee.study_mode = record[:study_mode]
              trainee.course_id = course.id
            end
            Rails.logger.info "Candidate #{record[:candidate_id]} created successfully: provider code #{record[:training_provider_code]} and course code #{record[:itt_course_code]} found!"
          else
            Rails.logger.info "Candidate #{record[:candidate_id]} invalid: course code #{record[:itt_course_code]} not found"
          end
        end
      end

      private

      def fetch_application_attributes(year:, changed_since: nil)
        applications = ::ApplyRegister::Api.call(year:, changed_since:)
        applications.fetch("data").each do |application_details|
          application_attributes = application_details["attributes"]
          @invalid_records << "Application status for candidate #{application_attributes["candidate"]["id"]} is invalid: #{application_attributes["status"]}" if invalid?(application_attributes)
          next if invalid?(application_attributes)

          @records << {
            status: application_attributes["status"],
            candidate_id: application_attributes["candidate"]["id"],
            itt_course_code: application_attributes["course"]["course_code"],
            itt_course_uuid: application_attributes["course"]["course_uuid"],
            training_provider_code: application_attributes["course"]["training_provider_code"],
            study_mode: application_attributes["course"]["study_mode"],
          }
        end
      end

      def invalid?(application_attributes)
        !%w[recruited].include?(application_attributes["status"])
      end
    end
  end
end
