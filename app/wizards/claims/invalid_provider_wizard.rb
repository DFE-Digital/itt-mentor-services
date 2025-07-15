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
      add_step(AddClaimWizard::ProviderOptionsStep) if steps.fetch(:provider).provider.blank?
    end

    def update_claim
      Claims::Claim::Submit.call(claim: updated_claim, user: created_by)
    end

    def setup_state
      state["provider"] = { "id" => nil }
    end

    def provider
      steps[:provider_options]&.provider || steps[:provider]&.provider
    end

    private

    def updated_claim
      claim.provider = steps.fetch(:provider).provider

      claim.mentor_trainings.each do |mentor_training|
        mentor_training.update!(provider: claim.provider)
      end

      claim
    end
  end
end
