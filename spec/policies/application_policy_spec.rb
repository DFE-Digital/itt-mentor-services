require "rails_helper"

RSpec.describe ApplicationPolicy do
  describe "ApplicationPolicy::Scope" do
    context "when the #resolve method is not implemented" do
      subject(:scope) { ApplicationPolicy::Scope.new(nil, nil) }

      it "raises a NoMethodError" do
        expect { scope.resolve }.to raise_error(NoMethodError, "You must define #resolve in #{scope.class}")
      end
    end
  end
end
