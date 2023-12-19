# == Schema Information
#
# Table name: gias_schools
#
#  id         :uuid             not null, primary key
#  address1   :string
#  address2   :string
#  address3   :string
#  name       :string           not null
#  postcode   :string
#  telephone  :string
#  town       :string
#  ukprn      :string
#  urn        :string           not null
#  website    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_gias_schools_on_urn  (urn) UNIQUE
#
require "rails_helper"

RSpec.describe GiasSchool, type: :model do
  subject { create(:gias_school) }

  describe "associations" do
    it do
      should have_one(:school).with_foreign_key(:urn).with_primary_key(:urn)
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:urn) }
    it { is_expected.to validate_uniqueness_of(:urn).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end
end
