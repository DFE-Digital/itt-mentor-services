module Claims
  class ExportUsersWizard::SpecificClaimWindowStep < BaseStep
    attribute :claim_window_id

    validate :claim_window_id_valid

    def claim_window
      @claim_window ||= ClaimWindow.find_by(id: claim_window_id)
    end

    def available_claim_windows
      Claims::ClaimWindow.order(starts_on: :desc)
    end

    private

    def claim_window_id_valid
      if claim_window_id.blank?
        errors.add(:claim_window_id, "Select a claim window")
      end
    end
  end
end
