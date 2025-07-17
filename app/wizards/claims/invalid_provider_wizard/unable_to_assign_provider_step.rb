class Claims::InvalidProviderWizard::UnableToAssignProviderStep < BaseStep
  delegate :provider, :claim, to: :wizard
  delegate :mentors, to: :claim
end
