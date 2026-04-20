class Claims::AddClaimWizard::ConfirmationStep < BaseStep
  attribute :confirmed, :boolean

  validates :confirmed, presence: true, acceptance: { accept: [true] }
end
