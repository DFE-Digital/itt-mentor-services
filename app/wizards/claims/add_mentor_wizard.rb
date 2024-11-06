module Claims
  class AddMentorWizard < BaseWizard
    attr_reader :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
      super(state:, params:, current_step:)
    end

    def define_steps
      add_step(MentorStep)
      if steps[:mentor].mentor.nil?
        add_step(NoResultsStep)
      else
        add_step(CheckYourAnswersStep) # Jamie did not use this step in his implementation of Claims::AddUserWizard
      end
    end

    def create_mentor
      raise "Invalid wizard state" unless valid?

      mentor.save! unless mentor.persisted?

      mentor_membership.save!
      mentor
    end

    private

    def mentor
      @mentor ||= steps[:mentor].mentor
    end

    def mentor_membership
      @mentor_membership ||= steps[:mentor].mentor_membership
    end
  end
end
