require "rails_helper"

RSpec.describe Claims::SchoolPolicy::Scope do
  subject(:school_policy) { described_class.new(user, Claims::School).resolve }

  let(:user) { create(:claims_user) }
  let(:associated_school) { create(:claims_school) }

  before do
    user.schools << associated_school
    create(:claims_school)
  end

  it "returns schools that the user is associated with" do
    expect(school_policy).to contain_exactly(associated_school)
  end
end
