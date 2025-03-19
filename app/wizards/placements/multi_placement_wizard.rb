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
      case appetite
      when "actively_looking"
        actively_looking_steps
      when "not_open"
        add_step(ReasonNotHostingStep)
      end
      add_step(SchoolContactStep)
      case appetite
      when "actively_looking"
        add_step(CheckYourAnswersStep)
      when "not_open"
        add_step(AreYouSureStep)
      when "interested"
        add_step(ConfirmStep)
      end
    end

    def update_school_placements
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

        create_placements

        create_partnerships

        wizard_school_contact.first_name = steps[:school_contact].first_name
        wizard_school_contact.last_name = steps[:school_contact].last_name
        wizard_school_contact.email_address = steps[:school_contact].email_address

        wizard_school_contact.save!
      end
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

    def selected_providers
      return Provider.none if steps[:provider].blank?

      provider_step = steps.fetch(:provider)
      if provider_step.provider_ids.include?(provider_step.class::SELECT_ALL)
        provider_step.providers
      else
        ::Provider.where(id: provider_step.provider_ids)
      end
    end

    def child_subject_placement_step_count
      steps.values.select { |step|
        step.is_a?(::Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep)
      }.count
    end

    private

    def create_placements
      selected_primary_subjects.each do |subject|
        placement_quantity_for_subject(subject).times do
          Placement.create!(school:, subject:, academic_year: upcoming_academic_year)
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

    def actively_looking_steps
      add_step(PhaseStep)
      if phases.include?(::Placements::School::PRIMARY_PHASE)
        primary_subject_steps
      end

      if phases.include?(::Placements::School::SECONDARY_PHASE)
        secondary_subject_steps
      end

      add_step(ProviderStep)
    end

    def primary_subject_steps
      add_step(PrimarySubjectSelectionStep)
      add_step(PrimaryPlacementQuantityStep)
      # No primary subject have child subjects
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

    def wizard_school_contact
      @wizard_school_contact = steps[:school_contact].school_contact
    end

    def subjects_known?
      subjects_known_step = steps.fetch(:subjects_known)
      subjects_known_step.subjects_known == subjects_known_step.class::YES
    end

    def appetite
      @appetite ||= steps.fetch(:appetite).appetite
    end

    def reasons_not_hosting
      @reasons_not_hosting ||= steps.fetch(:reason_not_hosting).reasons_not_hosting
    end

    def list_placements?
      list_placements_step = steps.fetch(:list_placements)
      list_placements_step.list_placements == list_placements_step.class::YES
    end

    def hosting_interest
      @hosting_interest ||= begin
        upcoming_interest = school.hosting_interests.for_academic_year(upcoming_academic_year).last
        upcoming_interest.presence || school.hosting_interests.build(academic_year: upcoming_academic_year)
      end
    end
  end
end
