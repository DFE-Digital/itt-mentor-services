module Placements
  class EditPlacementWizard < BaseWizard
    attr_reader :school, :placement, :current_user

    def initialize(current_user:, school:, params:, placement:, state:, current_step: nil)
      @school = school
      @placement = placement
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(ProviderStep) if %i[provider provider_options assign_last_placement].include?(current_step)
      add_step(ProviderOptionsStep) if steps[:provider].present? && steps.fetch(:provider).provider.blank?
      if steps[:provider].present? &&
          school.placements.available_placements_for_academic_year(
            current_user.selected_academic_year,
          ).count == 1
        add_step(AssignLastPlacementStep)
      end
      add_step(AddPlacementWizard::YearGroupStep) if current_step == :year_group
      add_step(AddPlacementWizard::MentorsStep) if current_step == :mentors
      add_step(AddPlacementWizard::TermsStep) if current_step == :terms
      add_step(KeyStageStep) if current_step == :key_stage
    end

    def update_placement
      raise "Invalid wizard state" unless valid?

      if steps[:provider].present?
        placement.provider = steps[:provider_options]&.provider ||
          steps[:provider].provider
      end

      if steps[:year_group].present?
        placement.year_group = steps[:year_group].year_group
      end

      if steps[:mentors].present?
        placement.mentors = steps[:mentors].mentors
      end

      if steps[:terms].present?
        placement.terms = steps[:terms].terms
      end

      if steps[:key_stage].present?
        placement.key_stage = steps[:key_stage].key_stage
      end

      placement.save!
    end

    def setup_state
      state["provider"] = { "provider_id" => placement.provider_id }
      state["year_group"] = { "year_group" => placement.year_group }
      state["mentors"] = { "mentor_ids" => placement.mentors.ids }
      state["terms"] = { "term_ids" => placement.terms.ids }
      state["key_stage"] = { "key_stage_id" => placement.key_stage_id }
    end
  end
end
