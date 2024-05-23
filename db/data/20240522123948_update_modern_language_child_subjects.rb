class UpdateModernLanguageChildSubjects < ActiveRecord::Migration[7.1]
  def up
    api_response = PublishTeacherTraining::Subject::Api.call
    child_subject_ids = modern_language_child_subject_ids(api_response.fetch("data"))

    subjects_data = api_response.fetch("included")

    assign_parent_subject(parent_subject: modern_languages, child_subject_ids:, subjects_data:)
  end

  def down
    return if modern_languages.blank?

    Subject.where(parent_subject: modern_languages).update_all(parent_subject_id: nil)
  end

  private

  def modern_languages
    @modern_languages ||= Subject.find_by(name: "Modern Languages")
  end

  def modern_language_child_subject_ids(data)
    subject_ids = []

    modern_language_subject_area = data.find do |subject_area|
      subject_area["id"] == "ModernLanguagesSubject"
    end

    modern_language_subject_area.dig("relationships", "subjects", "data").each do |subject_data|
      subject_ids << subject_data["id"]
    end

    subject_ids
  end

  def assign_parent_subject(parent_subject:, child_subject_ids:, subjects_data:)
    return if parent_subject.blank?

    child_subjects_data = subjects_data.select do |subject|
      child_subject_ids.include?(subject["id"])
    end

    child_subjects_data.each do |child_subject_data|
      subject_attributes = child_subject_data["attributes"]
      child_subject = Subject.find_by(
        name: subject_attributes["name"],
        code: subject_attributes["code"],
      )
      next if child_subject.blank?

      child_subject.update!(parent_subject:)
    end
  end
end
