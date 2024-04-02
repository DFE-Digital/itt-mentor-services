require "rails_helper"

describe Claims::Claim::RemoveEmptyMentorTrainingHours do
  subject(:service) { described_class.call(claim:) }

  let!(:claim) { create(:claim, reference: nil, status: :internal, school:) }
  let(:school) { create(:claims_school, urn: "1234") }

  it_behaves_like "a service object" do
    let(:params) { { claim: } }
  end

  describe "#call" do
    it "removes the mentor trainings without hours from a claim" do
      create(:mentor_training, hours_completed: nil, claim:)
      create(:mentor_training, hours_completed: nil, claim:)
      training_with_hours = create(:mentor_training, hours_completed: 20, claim:)
      expect { service }.to change(Claims::MentorTraining, :count).by(-2)

      expect(claim.mentor_trainings).to eq([training_with_hours])
    end
  end
end
