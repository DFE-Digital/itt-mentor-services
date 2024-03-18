module PublishTeacherTraining
  module Subject
    class Import
      include ServicePattern

      PRIMARY_IDS = %w[PrimarySubject].freeze
      SECONDARY_IDS = %w[SecondarySubject ModernLanguagesSubject].freeze

      def call
        fetch_subject
      end

      private

      def fetch_subject
        api_response = PublishTeacherTraining::Subject::Api.call
        data = api_response.fetch("data")
        # Find Primary Subjects IDs
        primary_subject_ids = fetch_subject_ids(subject_area_ids: PRIMARY_IDS, data:)
        secondary_subject_ids = fetch_subject_ids(subject_area_ids: SECONDARY_IDS, data:)

        subjects_data = api_response.fetch("included")
        # Sync Primary Subjects
        sync_subjects(
          subject_area: :primary,
          subject_ids: primary_subject_ids,
          subjects_data:,
        )

        # Sync Secondary Subjects
        sync_subjects(
          subject_area: :secondary,
          subject_ids: secondary_subject_ids,
          subjects_data:,
        )
      end

      def sync_subjects(subject_area:, subject_ids:, subjects_data:)
        subject_area_subjects_data = subjects_data.select do |subject|
          subject_ids.include?(subject["id"])
        end
        subject_area_subjects_data.each do |subject_data|
          subject_attributes = subject_data.fetch("attributes")
          begin
            ::Subject.find_or_create_by!(
              subject_area:,
              name: subject_attributes.fetch("name"),
              code: subject_attributes.fetch("code"),
            )
          rescue ActiveRecord::RecordInvalid => e
            Sentry.capture_exception(e)
          end
        end
      end

      def fetch_subject_ids(subject_area_ids:, data:)
        subject_ids = []

        subject_areas = data.select do |subject_area_data|
          subject_area_ids.include?(subject_area_data.fetch("id"))
        end
        subject_areas.each do |subject_area|
          subject_area.dig("relationships", "subjects", "data").each do |subject_data|
            subject_ids << subject_data["id"]
          end
        end

        subject_ids
      end
    end
  end
end
