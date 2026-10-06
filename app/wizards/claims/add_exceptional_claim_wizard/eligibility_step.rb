class Claims::AddExceptionalClaimWizard::EligibilityStep < BaseStep
  attribute :confirmed, :boolean

  validates :confirmed, presence: true, acceptance: { accept: [true] }

  delegate :school_name, :academic_year_name, :school_requires_onboarding?, to: :wizard
end
