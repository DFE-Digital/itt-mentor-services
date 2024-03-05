# == Schema Information
#
# Table name: trusts
#
#  id         :uuid             not null, primary key
#  name       :string           not null
#  uid        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_trusts_on_uid  (uid) UNIQUE
#
require "rails_helper"

RSpec.describe Trust, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:schools) }
  end

  describe "validations" do
    subject { create(:trust) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:uid) }
    it { is_expected.to validate_uniqueness_of(:uid).case_insensitive }
  end
end
