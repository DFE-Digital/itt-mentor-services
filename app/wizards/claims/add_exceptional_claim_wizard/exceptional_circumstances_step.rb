class Claims::AddExceptionalClaimWizard::ExceptionalCircumstancesStep < BaseStep
  attribute :confirmed, :boolean

  validates :confirmed, presence: true, acceptance: { accept: [true] }
end
