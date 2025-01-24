# == Schema Information
#
# Table name: provider_samplings
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  provider_id   :uuid             not null
#  sampling_id   :uuid             not null
#
# Indexes
#
#  index_provider_samplings_on_provider_id  (provider_id)
#  index_provider_samplings_on_sampling_id  (sampling_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (sampling_id => samplings.id)
#
require "rails_helper"

RSpec.describe Claims::ProviderSampling, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:sampling) }
    it { is_expected.to belong_to(:provider) }

    it { is_expected.to have_many(:provider_sampling_claims) }
    it { is_expected.to have_many(:claims) }
    it { is_expected.to have_many(:download_access_tokens).dependent(:destroy) }
  end

  describe "attachments" do
    it { is_expected.to have_one_attached(:csv_file) }
  end

  describe "delegations" do
    it { is_expected.to delegate_method(:email_addresses).to(:provider).with_prefix }
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
  end

  describe "#downloaded?" do
    let(:provider_sampling) { create(:provider_sampling, downloaded_at:) }

    context "when downloaded_at is present" do
      let(:downloaded_at) { Time.current }

      it "returns true" do
        expect(provider_sampling.downloaded?).to be(true)
      end
    end

    context "when downloaded_at is blank" do
      let(:downloaded_at) { nil }

      it "returns false" do
        expect(provider_sampling.downloaded?).to be(false)
      end
    end
  end
end
