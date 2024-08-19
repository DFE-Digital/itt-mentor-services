require "rails_helper"

RSpec.describe MentorDecorator do
  describe ".mentor_school_placements" do
    let(:school) { create(:placements_school) }
    let(:mentor) { create(:placements_mentor, schools: [school]) }
    let!(:placement) { create(:placement, mentors: [mentor], school:) }

    before do
      _random_placement = create(:placement)
    end

    it "returns the placements associated to the mentor and school" do
      decorated_mentor = mentor.decorate
      decorated_placement = placement.decorate
      result = decorated_mentor.mentor_school_placements(school)

      expect(result).to contain_exactly(decorated_placement)
    end
  end
end
