require "rails_helper"

RSpec.describe SchoolSENProvision, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:school) }
    it { is_expected.to belong_to(:sen_provision) }
  end
end
