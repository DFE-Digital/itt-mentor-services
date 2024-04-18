require "rails_helper"

RSpec.describe Claims::Mentor::CalculateRemainingMentorTrainingHoursForProvider do
  subject(:calculate_remaining_mentor_training_hours) { described_class.call(mentor:, provider:) }

  let(:mentor) { create(:claims_mentor) }
  let(:provider) { create(:claims_provider) }

  it_behaves_like "a service object" do
    let(:params) { { mentor:, provider: } }
  end

  it "returns the remaining claimable mentor training hours for a provider for a given mentor" do
    create(:mentor_training, mentor:, provider:, hours_completed: 12)
    create(:mentor_training, mentor:, provider:, hours_completed: 4)

    create(:mentor_training, hours_completed: 15, mentor:)

    expect(calculate_remaining_mentor_training_hours).to eq(4)
  end
end
