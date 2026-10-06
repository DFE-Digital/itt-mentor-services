module Claims
  class AddExceptionalClaimWizard < ClaimBaseWizard
    attr_reader :created_by

    def initialize(created_by:, params:, state:, current_step: nil)
      @created_by = created_by
      super(state:, params:, current_step:)
    end

    delegate :amount, to: :claim
    delegate :name, :region_funding_available_per_hour, to: :school, prefix: true, allow_nil: true
    delegate :name, to: :provider, prefix: true, allow_nil: true
    delegate :name, to: :academic_year, prefix: true, allow_nil: true

    def define_steps
      add_step(ExceptionalCircumstancesStep)
      add_step(ClaimWindowStep)
      add_step(SchoolStep)
      add_step(SchoolOptionsStep) if steps.fetch(:school).school.blank?
      add_step(EligibilityStep) if school_requires_eligibility?
      add_step(::Claims::AddClaimWizard::ProviderStep)
      add_step(::Claims::AddClaimWizard::ProviderOptionsStep) if steps.fetch(:provider).provider.blank?
      if mentors_with_claimable_hours.any?
        add_step(MentorStep)
        steps.fetch(:mentor).selected_mentors.each do |mentor|
          add_step(::Claims::AddClaimWizard::MentorTrainingStep, { mentor_id: mentor.id }, :mentor_id)
        end
        add_step(::Claims::AddClaimWizard::ConfirmationStep)
        add_step(ClaimStatusStep)
        add_step(CheckYourAnswersStep)
      else
        add_step(NoMentorsStep)
      end
    end

    def claim_window
      steps.fetch(:claim_window).claim_window
    end

    def academic_year
      claim_window&.academic_year
    end

    def school
      steps[:school_options]&.school || steps.fetch(:school).school
    end

    def provider
      steps[:provider_options]&.provider || steps.fetch(:provider).provider
    end

    def claim
      @claim ||= Claims::Claim.new(
        provider:,
        school:,
        created_by:,
        claim_window:,
        mentor_trainings_attributes: mentor_training_steps.map do |mentor_training_step|
          {
            mentor_id: mentor_training_step.mentor_id,
            hours_completed: mentor_training_step.hours_completed,
            training_type: mentor_training_step.training_type,
            provider:,
          }
        end,
      )
    end

    def claim_to_exclude; end

    def mentors_with_claimable_hours
      return Claims::Mentor.none if provider.blank? || school.blank? || claim_window.blank?

      @mentors_with_claimable_hours ||= Claims::MentorsWithRemainingClaimableHoursQuery.call(
        params: {
          school:,
          provider:,
          claim: Claims::Claim.new(claim_window:),
        },
      )
    end

    def claim_status_attributes
      status_step = steps.fetch(:claim_status)
      return { status: :submitted } unless status_step.paid?

      { status: :paid, paid_to_la: status_step.paid_to_la?, date_paid: status_step.date_paid_time }
    end

    def school_requires_onboarding?
      school.present? && !school.claims_service?
    end

    def school_requires_eligibility?
      school.present? && claim_window.present? && !school.eligible_for_claim_window?(claim_window)
    end

    def create_claim
      raise "Invalid wizard state" unless valid?

      requires_onboarding = school_requires_onboarding?
      requires_eligibility = school_requires_eligibility?

      ActiveRecord::Base.transaction do
        school.update!(claims_service: true, manually_onboarded_by: created_by) if requires_onboarding
        school.eligibilities.find_or_create_by!(academic_year:) if requires_eligibility
        Claims::Claim::SubmitOnBehalfOfSchool.call(claim:, support_user: created_by, **claim_status_attributes)
      end
    end
  end
end
