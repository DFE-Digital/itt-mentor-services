module Placements
  class EditSchoolContactWizard < BaseWizard
    attr_reader :school, :school_contact

    def initialize(school:, params:, school_contact:, state:, current_step: nil)
      @school = school
      @school_contact = school_contact
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(AddSchoolContactWizard::SchoolContactStep)
    end

    def update_school_contact
      raise "Invalid wizard state" unless valid?

      school_contact.update!(
        first_name: steps[:school_contact].first_name,
        last_name: steps[:school_contact].last_name,
        email_address: steps[:school_contact].email_address,
      )
    end

    def setup_state
      state["school_contact"] = {
        "first_name" => school_contact.first_name,
        "last_name" => school_contact.last_name,
        "email_address" => school_contact.email_address,
      }
    end
  end
end
