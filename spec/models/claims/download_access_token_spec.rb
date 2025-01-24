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
require 'rails_helper'

RSpec.describe Claims::DownloadAccessToken, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:activity_record) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:activity_record) }
    it { is_expected.to validate_presence_of(:email_address) }
  end
end
