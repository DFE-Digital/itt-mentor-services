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
FactoryBot.define do
  factory :download_access_token, class: 'Claims::DownloadAccessToken' do
    email_address { "example@example.com" }

    association :activity_record, factory: :provider_sampling
  end
end
