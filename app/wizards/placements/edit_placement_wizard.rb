module Placements
  class EditPlacementWizard < BaseWizard
    attr_reader :school, :placement

    def initialize(school:, params:, placement:, state:, current_step: nil)
      @school = school
      @placement = placement
      super(state:, params:, current_step:)
    end

    def define_steps
      # Define the wizard steps here
      add_step(ProviderStep) if current_step == :provider
      add_step(AddPlacementWizard::YearGroupStep) if current_step == :year_group
      add_step(AddPlacementWizard::MentorsStep) if current_step == :mentors
      add_step(AddPlacementWizard::TermsStep) if current_step == :terms
    end

    def update_placement
      raise "Invalid wizard state" unless valid?

      if steps[:provider].present?
        placement.provider = steps[:provider].provider
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

      placement.save!
    end

    def setup_state
      state["provider"] = { "provider_id" => placement.provider_id }
      state["year_group"] = { "year_group" => placement.year_group }
      state["mentors"] = { "mentor_ids" => placement.mentors.ids }
      state["terms"] = { "term_ids" => placement.terms.ids }
    end
  end
end
