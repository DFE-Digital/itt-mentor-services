require "rails_helper"

describe Claims::School::AcceptGrantConditions do
  subject(:grant_conditions) { described_class.call(school:, user:) }

  let(:school) { create(:claims_school, :claims, urn: "123457", claims_grant_conditions_accepted_at: nil) }

  let(:user) do
    create(
      :claims_user,
      :anne,
      user_memberships: [create(:user_membership, organisation: school)],
    )
  end

  before do
    Timecop.freeze(Time.zone.parse("25 April 2024 12:00"))
  end

  after do
    Timecop.return
  end

  it_behaves_like "a service object" do
    let(:params) { { school:, user: } }
  end

  it "updates the school's claims_grant_conditions_accepted_at and claims_grant_conditions_accepted_by_id" do
    grant_conditions
    expect(school.claims_grant_conditions_accepted_by_id).to eq(user.id)
    expect(school.claims_grant_conditions_accepted_at).to eq("Thu, 25 Apr 2024 12:00:00.000000000 UTC +00:00")
  end
end
