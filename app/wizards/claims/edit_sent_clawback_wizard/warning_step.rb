class Claims::EditSentClawbackWizard::WarningStep < BaseStep
  delegate :claim, :audit_log_path, to: :wizard
  delegate :school, to: :claim
end
