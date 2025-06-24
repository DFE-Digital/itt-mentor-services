module Placements
  class MultiPlacementWizard < BaseWizard
    include ::Placements::MultiPlacementCreatable

    attr_reader :school, :current_user, :created_placements

    delegate :school_contact, to: :school

    def initialize(current_user:, school:, params:, state:, current_step: nil)
      @school = school
      @current_user = current_user
      super(state:, params:, current_step:)
    end

    def define_steps
      add_placement_creation_steps
    end

    def update_school_placements
      raise "Invalid wizard state" unless valid?

      @created_placements = ApplicationRecord.transaction do
        create_placements
      end
    end

    def academic_year
      @academic_year ||= @current_user.selected_academic_year
    end
  end
end
