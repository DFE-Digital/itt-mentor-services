require "rails_helper"
require Rails.root.join("db/migrate/20261103100100_backfill_grant_conditions_acceptances")

RSpec.describe BackfillGrantConditionsAcceptances do
  subject(:migrate) { described_class.new.up }

  let(:user) { create(:claims_user) }
  let(:previous_year) { AcademicYear.current.previous }

  def acceptances
    Claims::GrantConditionsAcceptance.pluck(:school_id, :academic_year_id, :accepted_by_id)
  end

  it "records an acceptance for the academic year the grant conditions were accepted in" do
    accepted_at = previous_year.starts_on.to_time + 1.month
    school = create(:claims_school, grant_conditions_accepted: false, claims_grant_conditions_accepted_at: accepted_at, claims_grant_conditions_accepted_by_id: user.id)

    migrate

    expect(acceptances).to contain_exactly([school.id, previous_year.id, user.id])
    expect(Claims::GrantConditionsAcceptance.last.accepted_at).to be_within(1.second).of(accepted_at)
  end

  it "does not record an acceptance for schools that have not accepted the grant conditions" do
    create(:claims_school, grant_conditions_accepted: false, claims_grant_conditions_accepted_at: nil, claims_grant_conditions_accepted_by_id: nil)

    migrate

    expect(acceptances).to be_empty
  end

  it "does not record an acceptance when the accepting user is unknown" do
    create(:claims_school, grant_conditions_accepted: false, claims_grant_conditions_accepted_at: Time.current, claims_grant_conditions_accepted_by_id: nil)

    migrate

    expect(acceptances).to be_empty
  end

  it "skips schools that already have an acceptance for that academic year" do
    school = create(:claims_school, grant_conditions_accepted: false, claims_grant_conditions_accepted_at: Time.current, claims_grant_conditions_accepted_by_id: user.id)
    create(:grant_conditions_acceptance, school:, academic_year: AcademicYear.current, accepted_by: user)

    expect { migrate }.not_to change(Claims::GrantConditionsAcceptance, :count)
  end
end
