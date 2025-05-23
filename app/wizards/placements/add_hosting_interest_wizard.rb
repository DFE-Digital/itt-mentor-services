module Placements
  class AddHostingInterestWizard < BaseWizard
    attr_reader :school

    delegate :school_contact, to: :school

    UNKNOWN_OPTION = "unknown".freeze

    def initialize(school:, params:, state:, current_step: nil)
      @school = school
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

    def upcoming_academic_year
      @upcoming_academic_year ||= AcademicYear.current.next
    end

    def selected_secondary_subjects
      return [UNKNOWN_OPTION] if selected_secondary_subject_ids.include?(UNKNOWN_OPTION)

      Subject.secondary.where(id: selected_secondary_subject_ids).order_by_name
    end

    def placement_quantity_for_subject(subject)
      return 0 if steps[:secondary_placement_quantity].blank?

      steps.fetch(:secondary_placement_quantity).try(subject.name_as_attribute).to_i
    end

    def placement_quantity_for_year_group(year_group)
      return 0 if steps[:year_group_placement_quantity].blank?

      steps.fetch(:year_group_placement_quantity).try(year_group.to_sym).to_i
    end

    def child_subject_placement_step_count
      steps.values.select { |step|
        step.is_a?(::Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep)
      }.count
    end

    def year_groups
      return [] if steps[:year_group_selection].blank?

      @year_groups ||= steps.fetch(:year_group_selection).year_groups
    end

    def placements_information
      primary_placement_information.merge(
        secondary_placement_information,
      )
    end

    private

    def create_placements
      year_groups.each do |year_group|
        placement_quantity_for_year_group(year_group).times do
          Placement.create!(
            school:,
            subject: Subject.primary_subject,
            year_group:,
            academic_year: upcoming_academic_year,
          )
        end
      end

      selected_secondary_subjects.each do |subject|
        placement_quantity_for_subject(subject).times do |i|
          placement = Placement.create!(school:, subject:, academic_year: upcoming_academic_year)
          next unless subject.has_child_subjects?

          step_name = step_name_for_child_subjects(subject:, selection_number: i + 1)
          steps.fetch(step_name).child_subject_ids.each do |child_subject_id|
            placement.additional_subjects << Subject.find(child_subject_id)
          end
          placement.save!
        end
      end
    end

    def selected_primary_subject_ids
      return [] if steps[:primary_subject_selection].blank?

      steps.fetch(:primary_subject_selection).subject_ids
    end

    def selected_secondary_subject_ids
      return [] if steps[:secondary_subject_selection].blank?

      steps.fetch(:secondary_subject_selection).subject_ids
    end

    def actively_looking_steps
      add_step(MultiPlacementWizard::PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        year_group_steps
      end

      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end
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
        add_step(MultiPlacementWizard::YearGroupSelectionStep)
        add_step(MultiPlacementWizard::YearGroupPlacementQuantityStep)
      end
    end

    def secondary_subject_steps
      if appetite_interested?
        add_step(Interested::SecondarySubjectSelectionStep)
        return if value_unknown(selected_secondary_subject_ids)

        add_step(Interested::SecondaryPlacementQuantityKnownStep)
        return unless steps.fetch(:secondary_placement_quantity_known).is_quantity_known?

        add_step(Interested::SecondaryPlacementQuantityStep)
      else
        add_step(MultiPlacementWizard::SecondarySubjectSelectionStep)
        add_step(MultiPlacementWizard::SecondaryPlacementQuantityStep)
      end
      child_subject_steps
    end

    def child_subject_steps
      if selected_secondary_subjects.any?(&:has_child_subjects?)
        selected_secondary_subjects.each do |subject|
          next unless subject.has_child_subjects?

          placement_quantity_for_subject(subject).times do |i|
            index = i + 1
            add_step(step_prefix::SecondaryChildSubjectPlacementSelectionStep,
                     {
                       selection_id: "#{subject.name_as_attribute}_#{index}",
                       selection_number: index,
                       parent_subject_id: subject.id,

                     },
                     :selection_id)
          end
        end
      end
    end

    def step_name_for_child_subjects(subject:, selection_number:)
      step_name(
        ::Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep,
        "#{subject.name_as_attribute}_#{selection_number}",
      )
    end

    def phases
      @phases = steps.fetch(:phase).phases
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
        upcoming_interest = school.hosting_interests.for_academic_year(upcoming_academic_year).last
        upcoming_interest.presence || school.hosting_interests.build(academic_year: upcoming_academic_year)
      end
    end

    def value_unknown(value)
      value.include?(UNKNOWN_OPTION)
    end

    def primary_placement_information
      return {} if steps[:year_group_selection].blank?

      primary_placement_details = {}
      primary_placement_details["year_group_selection"] = {
        "year_groups" => steps.fetch(:year_group_selection).year_groups,
      }
      if steps[:year_group_placement_quantity].present?
        primary_placement_details["year_group_placement_quantity"] = {}
        year_groups.each do |year_group|
          primary_placement_details["year_group_placement_quantity"][year_group] = placement_quantity_for_year_group(year_group)
        end
      end
      primary_placement_details
    end

    def secondary_placement_information
      return {} if steps[:secondary_subject_selection].blank?

      secondary_placement_details = {}
      secondary_placement_details["secondary_subject_selection"] = {
        "subject_ids" => steps.fetch(:secondary_subject_selection).subject_ids,
      }
      if steps[:secondary_placement_quantity].present?
        secondary_placement_details["secondary_placement_quantity"] = {}
        selected_secondary_subjects.each do |subject|
          secondary_placement_details["secondary_placement_quantity"][subject.name_as_attribute.to_s] = placement_quantity_for_subject(subject)
          next unless subject.has_child_subjects?

          secondary_placement_details["secondary_child_subject_placement_selection"] ||= {}
          secondary_placement_details["secondary_child_subject_placement_selection"][subject.name_as_attribute.to_s] = {}
          placement_quantity_for_subject(subject).times do |i|
            selection_number = i + 1
            step_name = step_name_for_child_subjects(subject:, selection_number:)
            child_subject_step = steps.fetch(step_name)
            secondary_placement_details["secondary_child_subject_placement_selection"][subject.name_as_attribute.to_s][selection_number.to_s] = {
              parent_subject_id: child_subject_step.parent_subject_id,
              selection_id: child_subject_step.selection_id,
              selection_number: child_subject_step.selection_number,
              child_subject_ids: child_subject_step.child_subject_ids,
            }
          end
        end
      end
      secondary_placement_details
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

    def step_prefix
      @step_prefix ||= if appetite_interested?
                         Interested
                       else
                         MultiPlacementWizard
                       end
    end
  end
end
