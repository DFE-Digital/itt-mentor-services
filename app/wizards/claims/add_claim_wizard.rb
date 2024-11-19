module Claims
  class AddClaimWizard < BaseWizard
    attr_reader :school, :created_by

    def initialize(school:, created_by:, params:, state:, current_step: nil)
      @school = school
      @created_by = created_by
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(ProviderStep)
      if mentors_with_claimable_hours.any? || current_step == :check_your_answers
        add_step(MentorStep)
        # Loop over mentors
        steps.fetch(:mentor).selected_mentors.each do |mentor|
          add_step(MentorTrainingStep, { mentor_id: mentor.id })
        end
        add_step(CheckYourAnswersStep)
      else
        add_step(NoMentorsStep)
      end
    end

    def add_step(step_class, preset_attributes = {})
      name = step_name(step_class, preset_attributes[:mentor_id])
      attributes = step_attributes(name, step_class, preset_attributes)
      @steps[name] = step_class.new(wizard: self, attributes:)
    end

    def academic_year
      Claims::ClaimWindow.current.academic_year
    end

    def total_hours
      mentor_training_steps.values.map(&:total_hours_completed).sum
    end

    def claim
      @claim ||= Claims::Claim.new(
        provider:,
        school:,
        created_by:,
        claim_window: Claims::ClaimWindow.current,
        mentor_trainings_attributes: mentor_training_steps.map do |_k, v|
          {
            mentor_id: v.mentor_id,
            hours_completed: v.total_hours_completed,
            provider:,
          }
        end,
      )
    end

    def create_claim
      if created_by.support_user?
        Claims::Claim::CreateDraft.call(claim:)
      else
        Claims::Claim::Submit.call(claim:, user: created_by)
      end
    end

    def mentors_with_claimable_hours
      return Claims::Mentor.none if provider.blank?

      @mentors_with_claimable_hours ||= Claims::MentorsWithRemainingClaimableHoursQuery.call(
        params: {
          school:,
          provider:,
          claim: Claims::Claim.new(academic_year:),
        },
      )
    end

    def provider
      steps.fetch(:provider).provider
    end

    private

    def step_name(step_class, id = nil)
      # e.g. YearGroupStep becomes :year_group
      name = super(step_class)
      return name.to_sym if id.blank?

      # e.g. with id it becomes :year_group_#{id}
      "#{name}_#{id}".to_sym
    end

    def step_attributes(name, step_class, preset_attributes = {})
      attributes = super(name, step_class)
      return attributes if preset_attributes.blank?

      attributes = {} if attributes.blank?
      attributes.merge(preset_attributes)
    end

    def mentor_training_steps
      steps.select { |k, _v| k.to_s.include?("mentor_training_") }
    end
  end
end
