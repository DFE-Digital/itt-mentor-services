module Claims
  class ExportUsersWizard::SpecificClaimWindowStep < BaseStep
    attribute :claim_window_id

    validate :claim_window_id_valid

    def claim_window
      @claim_window ||= ClaimWindow.find_by(id: claim_window_id)
    end

    def available_claim_windows
      Claims::ClaimWindow.order(starts_on: :desc).decorate
    end

    private

    def claim_window_id_valid
      if claim_window_id.blank?
        errors.add(:claim_window_id, I18n.t("wizards.claims.export_users_wizard.specific_claim_window_step.select_a_claim_window"))
      end
    end
  end
end
