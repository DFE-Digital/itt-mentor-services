module Placements
  class AddSchoolContactWizard < BaseWizard
    attr_reader :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(SchoolContactStep)
      add_step(CheckYourAnswersStep)
    end

    def create_school_contact
      raise "Invalid wizard state" unless valid?

      school_contact = steps.fetch(:school_contact).school_contact
      school_contact.save!
    end
  end
end
