# == Schema Information
#
# Table name: school_sen_provisions
#
#  id               :uuid             not null, primary key
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  school_id        :uuid             not null
#  sen_provision_id :uuid             not null
#
# Indexes
#
#  index_school_sen_provisions_on_school_id         (school_id)
#  index_school_sen_provisions_on_sen_provision_id  (sen_provision_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (sen_provision_id => sen_provisions.id)
#
require "rails_helper"

RSpec.describe SchoolSENProvision, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:sen_provision) }
  end
end
