require "rails_helper"

describe Claims::MentorForm, type: :model do
  it_behaves_like "a mentor form" do
    let(:mentor_class) { Claims::Mentor }
    let(:mentor_membership_class) { Claims::MentorMembership }
    let(:form_params_key) { "claims_mentor_form" }
    let(:mentor) { create(:claims_mentor, trn:) }
  end
end
