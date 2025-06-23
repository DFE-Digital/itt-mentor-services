module Placements
  class ConvertPotentialPlacementWizard < BaseWizard
    include ::Placements::MultiPlacementCreatable

    attr_reader :school, :current_user

    delegate :potential_placement_details, to: :school

    def initialize(current_user:, school:, params:, state:, current_step: nil)
      @school = school
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      if detail_unknown?
        add_placement_creation_steps
      else
        add_step(ConvertPlacementStep)
        if convert?
          add_step(SelectPlacementStep)
        else
          add_placement_creation_steps
        end
      end
    end

    def convert_placements
      ApplicationRecord.transaction do
        if steps[:select_placement].present?
          select_placement_step = steps.fetch(:select_placement)
          selected_year_groups = select_placement_step.year_groups
          selected_subject_ids = select_placement_step.subject_ids
          selected_key_stage_ids = select_placement_step.key_stage_ids

          selected_year_groups.each do |year_group|
            placement_count(phase: :primary, key: year_group).times do
              Placement.create!(
                school:,
                subject: Subject.primary_subject,
                year_group:,
                academic_year:,
                creator: current_user,
              )
            end
          end

          selected_subject_ids.each do |subject_id|
            subject = Subject.find(subject_id)
            placement_count(phase: :secondary, key: subject.name_as_attribute.to_s).times do |i|
              placement = Placement.create!(
                school:,
                subject:,
                academic_year:,
                creator: current_user,
              )
              next unless subject.has_child_subjects?

              child_subject_details = potential_placement_details.dig(
                "secondary_child_subject_placement_selection",
                subject.name_as_attribute.to_s,
              )
              child_subject_details.dig((i + 1).to_s, "child_subject_ids").each do |child_subject_id|
                placement.additional_subjects << Subject.find(child_subject_id)
              end
              placement.save!
            end
          end

          selected_key_stage_ids.each do |key_stage_id|
            key_stage = KeyStage.find(key_stage_id)
            placement_count(phase: :send, key: key_stage.name_as_attribute.to_s).times do
              Placement.create!(
                school:,
                key_stage:,
                academic_year:,
                creator: current_user,
                send_specific: true,
              )
            end
          end
        else
          create_placements
        end

        school.update!(potential_placement_details: nil)
        hosting_interest.update!(appetite: "actively_looking")
      end
    end

    def placement_count(phase:, key:)
      if phase == :primary
        potential_placement_details.dig("year_group_placement_quantity", key).to_i
      elsif phase == :secondary
        potential_placement_details.dig("secondary_placement_quantity", key).to_i
      else
        potential_placement_details.dig("key_stage_placement_quantity", key).to_i
      end
    end

    def academic_year
      @academic_year ||= current_user.selected_academic_year
    end

    def convert?
      @convert ||= steps.fetch(:convert_placement).convert?
    end

    private

    def hosting_interest
      @hosting_interest ||= school.current_hosting_interest(academic_year:)
    end

    def detail_unknown?
      potential_placement_details.blank? ||
        value_unknown(
          potential_placement_details.map { |_k, v| v.values }.compact.flatten.uniq,
        ) ||
        (potential_placement_details["year_group_selection"].present? &&
          potential_placement_details["year_group_placement_quantity"].blank?) ||
        (potential_placement_details["secondary_subject_selection"].present? &&
          potential_placement_details["secondary_placement_quantity"].blank?) ||
        (potential_placement_details["key_stage_selection"].present? &&
          potential_placement_details["key_stage_placement_quantity"].blank?)
    end

    def value_unknown(value)
      value.include?(AddHostingInterestWizard::UNKNOWN_OPTION)
    end
  end
end
