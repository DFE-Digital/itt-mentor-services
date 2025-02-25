module Placements
  class MultiPlacementWizard < BaseWizard
    attr_reader :school

    delegate :school_contact, to: :school

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(AppetiteStep)
      if appetite == "not_open"
        add_step(ReasonNotHostingStep)
        add_step(HelpStep)
      end
      add_step(SchoolContactStep)
    end

    def update_school_placements
      raise "Invalid wizard state" unless valid?

      hosting_interest.appetite = appetite
      if steps[:reason_not_hosting].present?
        hosting_interest.reasons_not_hosting = reasons_not_hosting
      end

      hosting_interest.save!

      wizard_school_contact.first_name = steps[:school_contact].first_name
      wizard_school_contact.last_name = steps[:school_contact].last_name
      wizard_school_contact.email_address = steps[:school_contact].email_address

      wizard_school_contact.save!
    end

    def upcoming_academic_year
      @upcoming_academic_year ||= AcademicYear.current.next
    end

    def setup_state
      unless hosting_interest.new_record?
        state["appetite"] = { "appetite" => hosting_interest.appetite }
        state["reason_not_hosting"] = { "reasons_not_hosting" => hosting_interest.reasons_not_hosting }
      end

      if school_contact.present?
        state["school_contact"] = {
          "first_name" => school_contact.first_name,
          "last_name" => school_contact.last_name,
          "email_address" => school_contact.email_address,
        }
      end
    end

    private

    def wizard_school_contact
      @wizard_school_contact = steps[:school_contact].school_contact
    end

    def appetite
      @appetite ||= steps.fetch(:appetite).appetite
    end

    def reasons_not_hosting
      @reasons_not_hosting ||= steps.fetch(:reason_not_hosting).reasons_not_hosting
    end

    def hosting_interest
      @hosting_interest ||= begin
        upcoming_interest = school.hosting_interests.for_academic_year(upcoming_academic_year).last
        upcoming_interest.presence || school.hosting_interests.build(academic_year: upcoming_academic_year)
      end
    end
  end
end
