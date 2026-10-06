# == Schema Information
#
# Table name: provider_eligibilities
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#  provider_id      :uuid             not null
#
# Indexes
#
#  index_provider_eligibilities_on_academic_year_id           (academic_year_id)
#  index_provider_eligibilities_on_provider_and_academic_year  (provider_id,academic_year_id) UNIQUE
#  index_provider_eligibilities_on_provider_id                (provider_id)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#  fk_rails_...  (provider_id => providers.id)
#
require "rails_helper"

RSpec.describe Claims::ProviderEligibility, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:academic_year) }
  end

  context "with validations" do
    subject(:eligibility) { described_class.new(provider: create(:provider), academic_year: AcademicYear.current) }

    it "does not allow a provider to be made eligible twice for the same academic year" do
      described_class.create!(provider: eligibility.provider, academic_year: eligibility.academic_year)

      expect(eligibility).not_to be_valid
    end

    it "allows a provider to be eligible for different academic years" do
      described_class.create!(provider: eligibility.provider, academic_year: eligibility.academic_year)
      next_year = AcademicYear.for_date(eligibility.academic_year.ends_on + 1.day)

      expect(described_class.new(provider: eligibility.provider, academic_year: next_year)).to be_valid
    end
  end

  it "is unique at the database level" do
    provider = create(:provider)
    described_class.create!(provider:, academic_year: AcademicYear.current)

    expect { described_class.new(provider:, academic_year: AcademicYear.current).save!(validate: false) }
      .to raise_error(ActiveRecord::RecordNotUnique)
  end
end
