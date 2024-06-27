require "rails_helper"

describe Placements::MentorForm, type: :model do
  it_behaves_like "a mentor form" do
    let(:mentor_class) { Placements::Mentor }
    let(:mentor_membership_class) { Placements::MentorMembership }
    let(:form_params_key) { "placements_mentor_form" }
    let(:mentor) { create(:placements_mentor, trn:) }
  end
end
