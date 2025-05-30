module Placements
  class MultiPlacementWizard < BaseWizard
    attr_reader :school, :current_user

    delegate :school_contact, to: :school

    def initialize(current_user:, school:, params:, state:, current_step: nil)
      @school = school
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(PhaseStep)
      add_step(MultiPlacementWizard::PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        year_group_steps
      end

      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end
      add_step(CheckYourAnswersStep)
    end

    def update_school_placements
      raise "Invalid wizard state" unless valid?

      ApplicationRecord.transaction do
        create_placements
      end
    end

    def upcoming_academic_year
      @upcoming_academic_year ||= AcademicYear.current.next
    end

    def selected_primary_subjects
      Subject.primary.where(id: selected_primary_subject_ids).order_by_name
    end

    def selected_secondary_subjects
      Subject.secondary.where(id: selected_secondary_subject_ids).order_by_name
    end

    def placement_quantity_for_subject(subject)
      if subject.primary?
        steps.fetch(:primary_placement_quantity)
      else
        steps.fetch(:secondary_placement_quantity)
      end.try(subject.name_as_attribute).to_i
    end

    def placement_quantity_for_year_group(year_group)
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

    private

    def create_placements
      year_groups.each do |year_group|
        placement_quantity_for_year_group(year_group).times do
          Placement.create!(
            school:,
            subject: Subject.primary_subject,
            year_group:,
            academic_year: upcoming_academic_year,
            creator: current_user,
          )
        end
      end

      selected_secondary_subjects.each do |subject|
        placement_quantity_for_subject(subject).times do |i|
          placement = Placement.create!(
            school:,
            subject:,
            academic_year: upcoming_academic_year,
            creator: current_user,
          )
          next unless subject.has_child_subjects?

          step_name = step_name_for_child_subjects(subject:, selection_number: i + 1)
          steps.fetch(step_name).child_subject_ids.each do |child_subject_id|
            placement.additional_subjects << Subject.find(child_subject_id)
          end
          placement.save!
        end
      end
    end

    def create_partnerships
      selected_providers.each do |provider|
        ::Placements::Partnership.find_or_create_by!(school:, provider:)
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

    def year_group_steps
      add_step(MultiPlacementWizard::YearGroupSelectionStep)
      add_step(MultiPlacementWizard::YearGroupPlacementQuantityStep)
    end

    def secondary_subject_steps
      add_step(SecondarySubjectSelectionStep)
      add_step(SecondaryPlacementQuantityStep)
      if selected_secondary_subjects.any?(&:has_child_subjects?)
        selected_secondary_subjects.each do |subject|
          next unless subject.has_child_subjects?

          placement_quantity_for_subject(subject).times do |i|
            index = i + 1
            add_step(SecondaryChildSubjectPlacementSelectionStep,
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
  end
end
