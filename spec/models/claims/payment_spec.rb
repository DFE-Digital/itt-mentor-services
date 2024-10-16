# == Schema Information
#
# Table name: payments
#
#  id         :uuid             not null, primary key
#  claim_ids  :string           default([]), is an Array
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sent_by_id :uuid             not null
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
  context "with associations" do
    it { is_expected.to belong_to(:sent_by).class_name("Claims::SupportUser") }
  end
end
