# == Schema Information
#
# Table name: claims
#
#  id         :uuid             not null, primary key
#  draft      :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  school_id  :uuid             not null
#
# Indexes
#
#  index_claims_on_school_id  (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Claim, type: :model do
  context "associations" do
    it { should belong_to(:school) }
    it { should have_many(:mentor_trainings) }
    it { should have_many(:mentors).through(:mentor_trainings) }
    it { should have_many(:providers).through(:mentor_trainings) }
    it { should accept_nested_attributes_for(:mentor_trainings) }
  end
end
