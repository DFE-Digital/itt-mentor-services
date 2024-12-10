# == Schema Information
#
# Table name: samplings
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "rails_helper"

RSpec.describe Claims::Sampling, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:provider_samplings) }
  end
end
