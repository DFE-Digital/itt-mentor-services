require "rails_helper"

RSpec.describe SENProvision, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:school_sen_provisions) }
    it { is_expected.to have_many(:schools).through(:school_sen_provisions) }
  end

  describe "validations" do
    subject { create(:sen_provision) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
