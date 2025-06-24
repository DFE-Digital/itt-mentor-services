module Placements::MultiPlacementCreatable
  extend ActiveSupport::Concern

  def add_placement_creation_steps(with_check_your_answers: true)
    add_step(::Placements::MultiPlacementWizard::PhaseStep)
    if primary_phase?
      year_group_steps
    end

    if secondary_phase?
      secondary_subject_steps
    end

    if send_specific?
      send_steps
    end
    return unless with_check_your_answers

    add_step(::Placements::MultiPlacementWizard::CheckYourAnswersStep)
  end

  def create_placements
    created_placements = []
    year_groups.each do |year_group|
      placement_quantity_for_year_group(year_group).times do
        placement = Placement.create!(
          school:,
          subject: Subject.primary_subject,
          year_group:,
          academic_year:,
          creator: current_user,
        )
        created_placements << placement
      end
    end

    selected_secondary_subjects.each do |subject|
      placement_quantity_for_subject(subject).times do |i|
        placement = Placement.create!(
          school:,
          subject:,
          academic_year:,
          creator: current_user,
        )
        next unless subject.has_child_subjects?

        step_name = step_name_for_child_subjects(subject:, selection_number: i + 1)
        steps.fetch(step_name).child_subject_ids.each do |child_subject_id|
          placement.additional_subjects << Subject.find(child_subject_id)
        end
        placement.save!
        created_placements << placement
      end
    end

    selected_key_stages.each do |key_stage|
      placement_quantity_for_key_stage(key_stage).times do
        placement = Placement.create!(
          school:,
          key_stage:,
          academic_year:,
          creator: current_user,
          send_specific: true,
        )
        created_placements << placement
      end
    end

    created_placements
  end

  def year_groups
    return [] if steps[:year_group_selection].blank?

    @year_groups ||= steps.fetch(:year_group_selection).year_groups
  end

  def selected_secondary_subjects
    @selected_secondary_subjects ||= Subject.secondary.where(
      id: selected_secondary_subject_ids,
    ).order_by_name
  end

  def selected_key_stages
    @selected_key_stages ||= ::Placements::KeyStage.where(
      id: selected_key_stage_ids,
    ).order_by_name
  end

  def placement_quantity_for_subject(subject)
    return 0 if steps[:secondary_placement_quantity].blank?

    steps.fetch(:secondary_placement_quantity).try(subject.name_as_attribute).to_i
  end

  def placement_quantity_for_year_group(year_group)
    return 0 if steps[:year_group_placement_quantity].blank?

    steps.fetch(:year_group_placement_quantity).try(year_group.to_sym).to_i
  end

  def placement_quantity_for_key_stage(key_stage)
    return 0 if steps[:key_stage_placement_quantity].blank?

    steps.fetch(:key_stage_placement_quantity).try(key_stage.name_as_attribute).to_i
  end

  def child_subject_placement_step_count
    steps.values.select { |step|
      step.is_a?(::Placements::MultiPlacementWizard::SecondaryChildSubjectPlacementSelectionStep)
    }.count
  end

  def academic_year
    raise NoMethodError, "#academic_year must be implemented"
  end

  def current_user
    raise NoMethodError, "#current_user must be implemented"
  end

  def placements_information
    primary_placement_information.merge(
      secondary_placement_information.merge(
        send_placement_information,
      ),
    )
  end

  private

  def year_group_steps
    add_step(::Placements::MultiPlacementWizard::YearGroupSelectionStep)
    add_step(::Placements::MultiPlacementWizard::YearGroupPlacementQuantityStep)
  end

  def selected_secondary_subject_ids
    return [] if steps[:secondary_subject_selection].blank?

    steps.fetch(:secondary_subject_selection).subject_ids
  end

  def selected_key_stage_ids
    return [] if steps[:key_stage_selection].blank?

    steps.fetch(:key_stage_selection).key_stage_ids
  end

  def secondary_subject_steps
    add_step(::Placements::MultiPlacementWizard::SecondarySubjectSelectionStep)
    add_step(::Placements::MultiPlacementWizard::SecondaryPlacementQuantityStep)
    child_subject_steps
  end

  def child_subject_steps(step_prefix: ::Placements::MultiPlacementWizard)
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

  def send_steps
    add_step(::Placements::MultiPlacementWizard::KeyStageSelectionStep)
    add_step(::Placements::MultiPlacementWizard::KeyStagePlacementQuantityStep)
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

  def send_placement_information
    return {} if steps[:key_stage_selection].blank?

    send_placement_details = {}
    send_placement_details["key_stage_selection"] = {
      "key_stage_ids" => steps.fetch(:key_stage_selection).key_stage_ids,
    }
    if steps[:key_stage_placement_quantity].present?
      send_placement_details["key_stage_placement_quantity"] = {}
      selected_key_stages.each do |key_stage|
        send_placement_details["key_stage_placement_quantity"][key_stage.name_as_attribute.to_s] = placement_quantity_for_key_stage(key_stage)
      end
    end
    send_placement_details
  end

  def primary_phase?
    phases.include?(::Placements::School::PRIMARY_PHASE)
  end

  def secondary_phase?
    phases.include?(::Placements::School::SECONDARY_PHASE)
  end

  def send_specific?
    phases.include?(::Placements::MultiPlacementWizard::PhaseStep::SEND)
  end
end
