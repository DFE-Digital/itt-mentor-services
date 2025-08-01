module Claims
  class ExportUsersWizard::ActivityLevelStep < BaseStep
    attribute :activity_selection

    validate :activity_selection_valid

    private

    def activity_selection_valid
      if activity_selection.blank?
        errors.add(:activity_selection, "Select which users to include")
      elsif !%w[all active].include?(activity_selection)
        errors.add(:activity_selection, "Select a valid activity level")
      end
    end
  end
end
