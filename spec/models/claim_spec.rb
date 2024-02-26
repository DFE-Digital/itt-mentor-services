# == Schema Information
#
# Table name: claims
#
#  id          :uuid             not null, primary key
#  draft       :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid             not null
#
# Indexes
#
#  index_claims_on_provider_id  (provider_id)
#  index_claims_on_school_id    (school_id)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#
require "rails_helper"

RSpec.describe Claim, type: :model do
  context "with associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to have_many(:mentor_trainings) }
    it { is_expected.to have_many(:mentors).through(:mentor_trainings) }
    it { is_expected.to accept_nested_attributes_for(:mentor_trainings) }
  end

  context "with delegations" do
    it { is_expected.to delegate_method(:name).to(:provider).with_prefix }
  end
end
