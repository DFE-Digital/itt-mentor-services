require "rails_helper"
require "./app/services/concerns/service_pattern" # needed until DFE-Digital/dfe-analytics#136 is fixed

RSpec.describe ServicePattern do
  describe "#call" do
    context "when the #call method is not implemented" do
      let(:test_class) { Class.new { include ServicePattern } }

      it "raises a NotImplementedError" do
        expect { test_class.call }.to raise_error(NoMethodError, "#call must be implemented")
      end
    end
  end
end
