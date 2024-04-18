require "rails_helper"

RSpec.describe Claims::Mentor::CalculateTotalMentorTrainingHoursForProvider do
  subject(:calculate_total_training_hours) { described_class.call(mentor:, provider:) }

  let!(:mentor) { create(:claims_mentor) }

  let!(:provider) { create(:claims_provider, :niot) }
  let!(:provider_2) { create(:claims_provider, :best_practice_network) }

  let!(:school) { create(:claims_school, :claims, name: "School name 1", region: regions(:inner_london), urn: "1234", local_authority_name: "blah", local_authority_code: "BLA", group: "Academy") }
  let!(:claim) { create(:claim, school:, reference: "12345678") }

  it_behaves_like "a service object" do
    let(:params) { { mentor:, provider: } }
  end

  it "returns the total mentor training hours for a provider for a given mentor" do
    create(:mentor_training, provider:, claim:, hours_completed: 20, mentor:)
    create(:mentor_training, provider:, claim:, hours_completed: 6, mentor:)

    create(:mentor_training, provider: provider_2, claim:, hours_completed: 20, mentor:)

    expect(calculate_total_training_hours).to eq(26)
  end
end
