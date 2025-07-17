module Claims
  class InvalidProviderWizard < ClaimBaseWizard
    attr_reader :school, :created_by, :claim

    def initialize(school:, claim:, created_by:, params:, state:, current_step: nil)
      @school = school
      @claim = claim
      @created_by = created_by
      super(state:, params:, current_step:)
    end

    delegate :name, to: :provider, prefix: true, allow_nil: true

    def define_steps
      add_step(AddClaimWizard::ProviderStep)
      return if mentors_with_claimable_hours.any?

      add_step(UnableToAssignProviderStep)
    end

    def update_claim
      Claims::Claim::Submit.call(claim: updated_claim, user: created_by)
    end

    def provider
      steps.fetch(:provider).provider
    end

    private

    def updated_claim
      claim.provider = steps.fetch(:provider).provider

      claim.mentor_trainings.each do |mentor_training|
        mentor_training.update!(provider: claim.provider)
      end

      claim
    end

    def mentors_with_claimable_hours
      return Claims::Mentor.none if provider.blank?

      @mentors_with_claimable_hours ||= Claims::MentorsWithRemainingClaimableHoursQuery.call(
        params: {
          school:,
          provider:,
          claim: Claims::Claim.new(claim_window: Claims::ClaimWindow.current),
        },
      )
    end
  end
end
