# == Schema Information
#
# Table name: partnerships
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid             not null
#  school_id   :uuid             not null
#
# Indexes
#
#  index_partnerships_on_provider_id                (provider_id)
#  index_partnerships_on_school_id                  (school_id)
#  index_partnerships_on_school_id_and_provider_id  (school_id,provider_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Placements::Partnership, type: :model do
  context "with associations" do
    describe "#school" do
      it { is_expected.to belong_to(:school) }

      it "returns a Placements::School record" do
        placements_school = create(:placements_school)
        placements_partnership = create(
          :placements_partnership,
          school: placements_school,
        )

        expect(placements_partnership.school).to eq(placements_school)
        expect(placements_partnership.school).to be_a(Placements::School)
      end
    end

    describe "#provider" do
      it { is_expected.to belong_to(:provider) }

      it "returns a Placements::Provider record" do
        placements_provider = create(:placements_provider)
        placements_partnership = create(
          :placements_partnership,
          provider: placements_provider,
        )

        expect(placements_partnership.provider).to eq(placements_provider)
        expect(placements_partnership.provider).to be_a(Placements::Provider)
      end
    end
  end

  context "with validations" do
    subject(:partnership) { build(:placements_partnership) }

    it { is_expected.to validate_uniqueness_of(:school_id).scoped_to(:provider_id).case_insensitive }
  end
end
