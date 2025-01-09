# == Schema Information
#
# Table name: payments
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  sent_by_id    :uuid             not null
#
# Indexes
#
#  index_payments_on_sent_by_id  (sent_by_id)
#
# Foreign Keys
#
#  fk_rails_...  (sent_by_id => users.id)
#
require "rails_helper"

RSpec.describe Claims::Payment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:sent_by).class_name("Claims::SupportUser") }
    it { is_expected.to have_many(:payment_claims).dependent(:destroy) }
    it { is_expected.to have_many(:claims).through(:payment_claims) }
    it { is_expected.to have_one_attached(:csv_file) }
  end

  describe "#downloaded?" do
    let(:payment) { create(:claims_payment, downloaded_at:) }

    context "when downloaded_at is present" do
      let(:downloaded_at) { Time.current }

      it "returns true" do
        expect(payment.downloaded?).to be(true)
      end
    end

    context "when downloaded_at is blank" do
      let(:downloaded_at) { nil }

      it "returns false" do
        expect(payment.downloaded?).to be(false)
      end
    end
  end
end
