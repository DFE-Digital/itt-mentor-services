module PublishTeacherTraining
  module Subject
    class Import
      include ServicePattern

      PRIMARY_ID = "PrimarySubject".freeze
      SECONDARY_ID = "SecondarySubject".freeze
      MODERN_LANGUAGES_ID = "ModernLanguagesSubject".freeze

      def call
        fetch_subject
      end

      private

      def fetch_subject
        api_response = PublishTeacherTraining::Subject::Api.call
        data = api_response.fetch("data")
        # Find Primary Subject IDs
        primary_subject_ids = fetch_subject_ids(subject_area_id: PRIMARY_ID, data:)
        # Find Secondary Subject IDs
        secondary_subject_ids = fetch_subject_ids(subject_area_id: SECONDARY_ID, data:)
        # Find Modern Language Subject IDs
        modern_language_subject_ids = fetch_subject_ids(subject_area_id: MODERN_LANGUAGES_ID, data:)

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

        # Sync Modern Language Subjects
        sync_subjects(
          subject_area: :secondary,
          subject_ids: modern_language_subject_ids,
          subjects_data:,
          parent_subject: ::Subject.find_by(name: "Modern Languages"),
        )
      end

      def sync_subjects(subject_area:, subject_ids:, subjects_data:, parent_subject: nil)
        return if subject_ids.blank?

        subject_area_subjects_data = subjects_data.select do |subject|
          subject_ids.include?(subject["id"])
        end
        subject_area_subjects_data.each do |subject_data|
          subject_attributes = subject_data.fetch("attributes")
          begin
            subject = ::Subject.find_or_create_by!(
              subject_area:,
              name: subject_attributes.fetch("name"),
              code: subject_attributes.fetch("code"),
            )
            # Parent subject assigned separately, in case the subject already
            # exists without the parent subject associated.
            next if parent_subject.blank?

            subject.update!(parent_subject:)
          rescue ActiveRecord::RecordInvalid => e
            Sentry.capture_exception(e)
          end
        end
      end

      def fetch_subject_ids(subject_area_id:, data:)
        subject_ids = []

        subject_area = data.find do |subject_area_data|
          subject_area_data["id"] == subject_area_id
        end

        return if subject_area.blank?

        subject_area.dig("relationships", "subjects", "data").each do |subject_data|
          subject_ids << subject_data["id"]
        end

        subject_ids
      end
    end
  end
end
