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
class Claims::PaymentResponse < ApplicationRecord
  belongs_to :user

  has_one_attached :csv_file

  validates :csv_file, presence: true

  def row_count
    @row_count ||= CSV.parse(csv_file.download, headers: true).length
  end

  def downloaded?
    downloaded_at.present?
  end
end
