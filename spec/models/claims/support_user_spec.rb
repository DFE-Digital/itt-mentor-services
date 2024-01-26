# == Schema Information
#
# Table name: users
#
#  id         :uuid             not null, primary key
#  email      :string           not null
#  first_name :string           not null
#  last_name  :string           not null
#  type       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_on_type_and_email  (type,email) UNIQUE
#
require "rails_helper"

RSpec.describe Claims::SupportUser do
  describe "#support_user?" do
    it "returns true" do
      expect(described_class.new.support_user?).to eq(true)
    end
  end

  describe "#service" do
    it "returns :claims" do
      expect(described_class.new.service).to eq(:claims)
    end
  end
end
