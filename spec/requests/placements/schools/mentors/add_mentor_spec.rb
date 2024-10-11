require "rails_helper"

RSpec.describe "'Add mentor' journey", service: :placements, type: :request do
  let(:current_user) { create(:placements_user, schools: [school]) }
  let(:start_path) { new_add_mentor_placements_school_mentors_path(school_id:) }

  it_behaves_like "an 'Add mentor' journey"

  private

  def step_path(step)
    add_mentor_placements_school_mentors_path(school_id:, state_key:, step:)
  end

  def school_mentors_path
    placements_school_mentors_path(school.id)
  end
end
