module Claims
  class ExportUsersWizard::ClaimWindowStep < BaseStep
    attribute :selection

    validate :selection_valid

    def all_claim_windows?
      selection == "all"
    end

    private

    def selection_valid
      if selection.blank?
        errors.add(:selection, I18n.t("wizards.claims.export_users_wizard.claim_window_step.select_claim_window"))
      end
    end
  end
end
