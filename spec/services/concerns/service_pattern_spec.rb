require "rails_helper"

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
