require "rails_helper"

describe Claims::School::AcceptGrantConditions do
  subject(:grant_conditions) { described_class.call(school:, user:) }

  let(:school) { create(:claims_school, urn: "123457", grant_conditions_accepted: false) }

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

  it "records the user who accepted the grant conditions for the current academic year" do
    expect { grant_conditions }.to change(school.grant_conditions_acceptances, :count).by(1)

    acceptance = school.grant_conditions_acceptances.last
    expect(acceptance.academic_year).to eq(AcademicYear.current)
    expect(acceptance.accepted_by).to eq(user)
    expect(acceptance.accepted_at).to eq(Time.zone.parse("25 April 2024 12:00"))
  end

  it "locks the school so concurrent acceptances do not conflict" do
    allow(school).to receive(:with_lock).and_call_original

    grant_conditions

    expect(school).to have_received(:with_lock)
  end

  context "when the latest claim window to open was for a previous academic year" do
    let(:previous_academic_year) { AcademicYear.current.previous }

    before do
      create(:claim_window, :historic, academic_year: previous_academic_year)
      create(:claim_window, :upcoming, academic_year: AcademicYear.current)
    end

    it "records the acceptance against the academic year of that claim window" do
      grant_conditions

      expect(school.grant_conditions_acceptances.last.academic_year).to eq(previous_academic_year)
    end
  end

  context "when the grant conditions were accepted for a previous academic year" do
    let!(:previous_acceptance) do
      create(:grant_conditions_acceptance, school:, academic_year: AcademicYear.current.previous, accepted_at: 1.year.ago)
    end

    it "keeps the previous acceptance and records a new one for the current academic year" do
      expect { grant_conditions }.to change(school.grant_conditions_acceptances, :count).by(1)

      expect(previous_acceptance.reload).to be_present
      expect(school.latest_grant_conditions_acceptance.academic_year).to eq(AcademicYear.current)
      expect(school.latest_grant_conditions_acceptance.accepted_by).to eq(user)
    end
  end

  context "when the grant conditions were already accepted for the current academic year" do
    let!(:existing_acceptance) do
      create(:grant_conditions_acceptance, school:, academic_year: AcademicYear.current, accepted_at: 1.week.ago)
    end

    it "updates the existing acceptance with the latest user and time" do
      expect { grant_conditions }.not_to change(school.grant_conditions_acceptances, :count)

      expect(existing_acceptance.reload.accepted_by).to eq(user)
      expect(existing_acceptance.accepted_at).to eq(Time.zone.parse("25 April 2024 12:00"))
    end
  end
end
