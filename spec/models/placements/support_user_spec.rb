# == Schema Information
#
# Table name: users
#
#  id                :uuid             not null, primary key
#  dfe_sign_in_uid   :string
#  email             :string           not null
#  first_name        :string           not null
#  last_name         :string           not null
#  last_signed_in_at :datetime
#  type              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Placements::SupportUser do
  describe "#support_user?" do
    it "returns true" do
      expect(described_class.new.support_user?).to eq(true)
    end
  end

  describe "#service" do
    it "returns :placements" do
      expect(described_class.new.service).to eq(:placements)
    end
  end
end
