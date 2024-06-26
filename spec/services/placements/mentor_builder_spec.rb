require "rails_helper"

RSpec.describe Placements::MentorBuilder do
  it_behaves_like "a mentor builder" do
    let(:mentor_class) { Placements::Mentor }
  end
end
