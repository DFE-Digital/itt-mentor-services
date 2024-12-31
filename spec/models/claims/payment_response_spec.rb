# == Schema Information
#
# Table name: payment_responses
#
#  id         :uuid             not null, primary key
#  processed  :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid             not null
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
end
