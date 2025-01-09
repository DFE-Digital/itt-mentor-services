# == Schema Information
#
# Table name: payment_responses
#
#  id            :uuid             not null, primary key
#  downloaded_at :datetime
#  processed     :boolean          default(FALSE)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  user_id       :uuid             not null
#
# Indexes
#
#  index_payment_responses_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
require "rails_helper"

RSpec.describe Claims::PaymentResponse, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_one_attached(:csv_file) }
  end

  describe "#downloaded?" do
    let(:payment_response) { create(:claims_payment_response, downloaded_at:) }

    context "when downloaded_at is present" do
      let(:downloaded_at) { Time.current }

      it "returns true" do
        expect(payment_response.downloaded?).to be(true)
      end
    end

    context "when downloaded_at is blank" do
      let(:downloaded_at) { nil }

      it "returns false" do
        expect(payment_response.downloaded?).to be(false)
      end
    end
  end
end
