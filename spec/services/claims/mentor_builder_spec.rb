require "rails_helper"

RSpec.describe Claims::MentorBuilder do
  it_behaves_like "a mentor builder" do
    let(:mentor_class) { Claims::Mentor }
  end
end
