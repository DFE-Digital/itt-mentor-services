module Placements
  class AddHostingInterestWizard < BaseWizard
    include ::Placements::MultiPlacementCreatable

    attr_reader :school, :current_user

    delegate :school_contact, to: :school

    UNKNOWN_OPTION = "unknown".freeze

    def initialize(current_user:, school:, params:, state:, current_step: nil)
      @school = school
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(AppetiteStep)
      case appetite
      when "actively_looking"
        actively_looking_steps
      when "not_open"
        not_open_steps
      when "interested"
        interested_steps
      end
    end

    def update_hosting_interest
      raise "Invalid wizard state" unless valid?

      ApplicationRecord.transaction do
        hosting_interest.appetite = appetite
        if steps[:reason_not_hosting].present?
          hosting_interest.reasons_not_hosting = reasons_not_hosting
          other_reason_not_hosting = steps
            .fetch(:reason_not_hosting)
            .other_reason_not_hosting
          hosting_interest.other_reason_not_hosting = (other_reason_not_hosting.presence)
        end

        hosting_interest.save!

        if appetite_interested?
          save_potential_placements_information
        else
          create_placements
        end

        school.update!(expression_of_interest_completed: true)

        wizard_school_contact.first_name = steps[:school_contact].first_name
        wizard_school_contact.last_name = steps[:school_contact].last_name
        wizard_school_contact.email_address = steps[:school_contact].email_address

        wizard_school_contact.save!
      end
    end

    def selected_secondary_subjects
      return [UNKNOWN_OPTION] if selected_secondary_subject_ids.include?(UNKNOWN_OPTION)

      super
    end

    def academic_year
      @academic_year ||= AcademicYear.current.next
    end

    private

    def actively_looking_steps
      add_placement_creation_steps(with_check_your_answers: false)
      add_step(SchoolContactStep)
      add_step(CheckYourAnswersStep)
    end

    def interested_steps
      add_step(Interested::PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        year_group_steps
      end
      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end
      add_step(Interested::NoteToProvidersStep)
      add_step(SchoolContactStep)
      add_step(ConfirmStep)
    end

    def not_open_steps
      add_step(ReasonNotHostingStep)
      add_step(NotOpen::SchoolContactStep)
      add_step(AreYouSureStep)
    end

    def year_group_steps
      if appetite_interested?
        add_step(Interested::YearGroupSelectionStep)
        return if value_unknown(year_groups)

        add_step(Interested::YearGroupPlacementQuantityKnownStep)
        return unless steps.fetch(:year_group_placement_quantity_known).is_quantity_known?

        add_step(Interested::YearGroupPlacementQuantityStep)
      else
        super
      end
    end

    def secondary_subject_steps
      if appetite_interested?
        add_step(Interested::SecondarySubjectSelectionStep)
        return if value_unknown(selected_secondary_subject_ids)

        add_step(Interested::SecondaryPlacementQuantityKnownStep)
        return unless steps.fetch(:secondary_placement_quantity_known).is_quantity_known?

        add_step(Interested::SecondaryPlacementQuantityStep)
        child_subject_steps(step_prefix: ::Placements::AddHostingInterestWizard::Interested)
      else
        super
      end
    end

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
        upcoming_interest = school.hosting_interests.for_academic_year(academic_year).last
        upcoming_interest.presence || school.hosting_interests.build(academic_year: academic_year)
      end
    end

    def value_unknown(value)
      value.include?(UNKNOWN_OPTION)
    end

    def save_potential_placements_information
      potential_placement_details = {}
      potential_placement_details[:phase] = {
        phases: steps.fetch(:phase).phases,
      }

      potential_placement_details = potential_placement_details
        .merge(placements_information)

      potential_placement_details[:note_to_providers] = {
        note: steps.fetch(:note_to_providers).note,
      }

      @school.update!(potential_placement_details:)
    end

    def appetite_interested?
      @appetite_interested ||= appetite == "interested"
    end
  end
end
