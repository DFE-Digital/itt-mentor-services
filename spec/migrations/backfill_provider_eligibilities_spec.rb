require "rails_helper"
require Rails.root.join("db/migrate/20261006100100_backfill_current_year_provider_eligibilities")
require Rails.root.join("db/migrate/20261006100200_backfill_provider_eligibilities_from_claims")

RSpec.describe "Provider eligibility backfill migrations" do
  let(:current_year) { AcademicYear.current }
  let(:previous_year) { AcademicYear.for_date(current_year.starts_on - 1.day) }
  let(:older_year) { AcademicYear.for_date(previous_year.starts_on - 1.day) }

  def eligibilities
    Claims::ProviderEligibility.pluck(:provider_id, :academic_year_id)
  end

  def window_for(academic_year)
    Claims::ClaimWindow.find_by(academic_year:) ||
      build(:claim_window, academic_year:, starts_on: academic_year.starts_on + 30.days, ends_on: academic_year.starts_on + 60.days).tap { |window| window.save!(validate: false) }
  end

  def create_claim(provider:, academic_year:, status: :submitted)
    create(:claim, provider:, claim_window: window_for(academic_year), status:)
  end

  describe BackfillCurrentYearProviderEligibilities do
    subject(:migrate) { described_class.new.up }

    let!(:accredited_provider) { create(:provider, accredited: true) }
    let!(:unaccredited_provider) { create(:provider, accredited: false) }

    before { Claims::ProviderEligibility.delete_all }

    it "makes accredited providers eligible for the current academic year" do
      migrate

      expect(eligibilities).to contain_exactly([accredited_provider.id, current_year.id])
    end

    it "does not make providers that are not accredited eligible" do
      migrate

      expect(Claims::ProviderEligibility.where(provider: unaccredited_provider)).to be_empty
    end

    it "does not create eligibilities for other academic years" do
      previous_year
      migrate

      expect(Claims::ProviderEligibility.where.not(academic_year: current_year)).to be_empty
    end

    it "skips providers that are already eligible" do
      Claims::ProviderEligibility.create!(provider: accredited_provider, academic_year: current_year)

      expect { migrate }.not_to change(Claims::ProviderEligibility, :count)
    end

    it "is safe to run twice" do
      migrate

      expect { described_class.new.up }.not_to change(Claims::ProviderEligibility, :count)
    end

    it "cannot be reversed" do
      expect { described_class.new.down }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end

  describe BackfillProviderEligibilitiesFromClaims do
    subject(:migrate) { described_class.new.up }

    let(:provider_a) { create(:provider, accredited: false) }
    let(:provider_b) { create(:provider, accredited: false) }
    let(:provider_without_claims) { create(:provider, accredited: false) }

    before do
      provider_without_claims
      Claims::ProviderEligibility.delete_all
    end

    it "makes a provider eligible for each academic year in which it has a claim" do
      create_claim(provider: provider_a, academic_year: current_year)
      create_claim(provider: provider_a, academic_year: previous_year)
      create_claim(provider: provider_b, academic_year: older_year)
      Claims::ProviderEligibility.delete_all

      migrate

      expect(eligibilities).to contain_exactly(
        [provider_a.id, current_year.id],
        [provider_a.id, previous_year.id],
        [provider_b.id, older_year.id],
      )
    end

    it "creates one eligibility however many claims a provider has in a year" do
      create_claim(provider: provider_a, academic_year: previous_year)
      create_claim(provider: provider_a, academic_year: previous_year, status: :paid)
      create_claim(provider: provider_a, academic_year: previous_year, status: :draft)
      Claims::ProviderEligibility.delete_all

      expect { migrate }.to change(Claims::ProviderEligibility, :count).by(1)
    end

    it "includes claims in every status except invalid provider" do
      Claims::Claim.statuses.keys.excluding("invalid_provider").each do |status|
        create_claim(provider: create(:provider, accredited: false), academic_year: previous_year, status:)
      end
      Claims::ProviderEligibility.delete_all

      migrate

      expect(Claims::ProviderEligibility.count).to eq(Claims::Claim.statuses.keys.size - 1)
    end

    it "includes claims in discarded claim windows" do
      create_claim(provider: provider_a, academic_year: older_year)
      Claims::ClaimWindow.find_by(academic_year: older_year).discard
      Claims::ProviderEligibility.delete_all

      migrate

      expect(eligibilities).to contain_exactly([provider_a.id, older_year.id])
    end

    it "ignores claims flagged as having an invalid provider" do
      create_claim(provider: provider_a, academic_year: current_year, status: :invalid_provider)
      Claims::ProviderEligibility.delete_all

      migrate

      expect(Claims::ProviderEligibility.where(provider: provider_a)).to be_empty
    end

    it "does not make providers without claims eligible" do
      create_claim(provider: provider_a, academic_year: previous_year)
      Claims::ProviderEligibility.delete_all

      migrate

      expect(Claims::ProviderEligibility.where(provider: provider_without_claims)).to be_empty
    end

    it "does not depend on the accredited flag" do
      accredited_without_claims = create(:provider, accredited: true)
      Claims::ProviderEligibility.delete_all

      migrate

      expect(Claims::ProviderEligibility.where(provider: accredited_without_claims)).to be_empty
    end

    it "skips eligibilities that already exist" do
      create_claim(provider: provider_a, academic_year: previous_year)

      expect { migrate }.not_to change(Claims::ProviderEligibility, :count)
    end

    it "is safe to run twice" do
      create_claim(provider: provider_a, academic_year: previous_year)
      Claims::ProviderEligibility.delete_all
      migrate

      expect { described_class.new.up }.not_to change(Claims::ProviderEligibility, :count)
    end

    it "cannot be reversed" do
      expect { described_class.new.down }.to raise_error(ActiveRecord::IrreversibleMigration)
    end
  end
end
