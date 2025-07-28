module Claims
  class ExportUsersWizard::ActivityLevelStep < BaseStep
    attribute :activity_selection

    validate :activity_selection_valid

    private

    def activity_selection_valid
      if activity_selection.blank?
        errors.add(:activity_selection, I18n.t("wizards.claims.export_users_wizard.activity_level_step.select_users"))
      elsif %w[all active].exclude?(activity_selection)
        errors.add(:activity_selection, I18n.t("wizards.claims.export_users_wizard.activity_level_step.select_valid_activity_level"))
      end
    end
  end
end
