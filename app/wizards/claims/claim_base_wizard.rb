module Claims
  class ClaimBaseWizard < BaseWizard
    def add_step(step_class, preset_attributes = {})
      name = step_name(step_class, preset_attributes[:mentor_id])
      attributes = step_attributes(name, step_class, preset_attributes)
      @steps[name] = step_class.new(wizard: self, attributes:)
    end

    def total_hours
      mentor_training_steps.map(&:hours_completed).sum
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

    def step_name_for_mentor(mentor)
      step_name(::Claims::AddClaimWizard::MentorTrainingStep, mentor.id)
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
      steps.values.select { |step| step.is_a?(::Claims::AddClaimWizard::MentorTrainingStep) }
    end
  end
end
