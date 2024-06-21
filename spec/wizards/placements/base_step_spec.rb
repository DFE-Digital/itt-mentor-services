require "rails_helper"

RSpec.describe Placements::BaseStep, type: :model do
  describe "attributes" do
    it { is_expected.to have_attributes(school: nil) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:school) }
  end
end
