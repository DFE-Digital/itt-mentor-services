# == Schema Information
#
# Table name: eligibilities
#
#  id               :uuid             not null, primary key
#  school_id        :uuid             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid
#
# Indexes
#
#  index_eligibilities_on_academic_year_id  (academic_year_id)
#  index_eligibilities_on_school_id         (school_id)
#

require "rails_helper"

RSpec.describe Claims::Eligibility, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:school).class_name("Claims::School") }
    it { is_expected.to belong_to(:academic_year) }
  end
end
