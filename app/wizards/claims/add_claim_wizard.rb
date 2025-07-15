module Claims
  class AddClaimWizard < ClaimBaseWizard
    attr_reader :school, :created_by

    def initialize(school:, created_by:, params:, state:, current_step: nil)
      @school = school
      @created_by = created_by
      super(state:, params:, current_step:)
    end

    delegate :amount, to: :claim
    delegate :name, :region_funding_available_per_hour, to: :school, prefix: true
    delegate :name, to: :provider, prefix: true, allow_nil: true
    delegate :name, to: :academic_year, prefix: true

    def define_steps
      add_step(ProviderStep)
      add_step(ProviderOptionsStep) if steps.fetch(:provider).provider.blank?
      if mentors_with_claimable_hours.any? || current_step == :check_your_answers
        add_step(MentorStep)
        # Loop over mentors
        steps.fetch(:mentor).selected_mentors.each do |mentor|
          add_step(MentorTrainingStep, { mentor_id: mentor.id }, :mentor_id)
        end
        add_step(CheckYourAnswersStep)
      else
        add_step(NoMentorsStep)
      end
    end

    def academic_year
      Claims::ClaimWindow.current.academic_year
    end

    def claim
      @claim ||= Claims::Claim.new(
        provider:,
        school:,
        created_by:,
        claim_window: Claims::ClaimWindow.current,
        mentor_trainings_attributes: mentor_training_steps.map do |mentor_training_step|
          {
            mentor_id: mentor_training_step.mentor_id,
            hours_completed: mentor_training_step.hours_completed,
            provider:,
          }
        end,
      )
    end

    def claim_to_exclude; end

    def create_claim
      if created_by.support_user?
        Claims::Claim::CreateDraft.call(claim:)
      else
        Claims::Claim::Submit.call(claim:, user: created_by)
      end
    end

    def provider
      steps[:provider_options]&.provider || steps.fetch(:provider).provider
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
