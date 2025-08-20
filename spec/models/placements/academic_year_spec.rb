# == Schema Information
#
# Table name: academic_years
#
#  id         :uuid             not null, primary key
#  ends_on    :date
#  name       :string
#  starts_on  :date
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Placements::AcademicYear, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:placements) }
    it { is_expected.to have_many(:hosting_interests) }
    it { is_expected.to have_many(:users) }
  end
end
