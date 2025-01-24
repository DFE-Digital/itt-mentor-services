# == Schema Information
#
# Table name: download_access_tokens
#
#  id                   :uuid             not null, primary key
#  activity_record_type :string           not null
#  downloaded_at        :datetime
#  email_address        :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  activity_record_id   :uuid             not null
#
# Indexes
#
#  index_download_access_tokens_on_activity_record  (activity_record_type,activity_record_id)
#
class Claims::DownloadAccessToken < ApplicationRecord
  generates_token_for :csv_download, expires_in: 7.days do
    downloaded_at
  end

  belongs_to :activity_record, polymorphic: true

  validates :email_address, presence: true
  validates :activity_record, presence: true
end
