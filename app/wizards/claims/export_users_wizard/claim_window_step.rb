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
        errors.add(:selection, "Select which claim windows to include")
      end
    end
  end
end
