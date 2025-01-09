# == Schema Information
#
# Table name: clawbacks
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require "rails_helper"

RSpec.describe Claims::Clawback, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:clawback_claims) }
    it { is_expected.to have_many(:claims).through(:clawback_claims) }
  end

  describe "attachments" do
    it { is_expected.to have_one_attached(:csv_file) }
  end

  describe "#downloaded?" do
    let(:clawback) { create(:claims_clawback, downloaded_at:) }

    context "when downloaded_at is present" do
      let(:downloaded_at) { Time.current }

      it "returns true" do
        expect(clawback.downloaded?).to be(true)
      end
    end

    context "when downloaded_at is blank" do
      let(:downloaded_at) { nil }

      it "returns false" do
        expect(clawback.downloaded?).to be(false)
      end
    end
  end
end
