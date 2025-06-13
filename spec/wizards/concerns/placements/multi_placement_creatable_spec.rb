require "rails_helper"

class MultiPlacementCreatableTestClass
  include Placements::MultiPlacementCreatable
end

RSpec.describe Placements::MultiPlacementCreatable do
  let(:test_class) { MultiPlacementCreatableTestClass.new }

  describe "#academic_year" do
    it "raises an error for not implementing an academic year method" do
      expect { test_class.academic_year }.to raise_error(NoMethodError, "#academic_year must be implemented")
    end
  end

  describe "#current_user" do
    it "raises an error for not implementing an current user method" do
      expect { test_class.current_user }.to raise_error(NoMethodError, "#current_user must be implemented")
    end
  end
end
