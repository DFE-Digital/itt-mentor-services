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
end
