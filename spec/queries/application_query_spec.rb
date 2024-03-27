require "rails_helper"

RSpec.describe ApplicationQuery do
  describe ".call" do
    context "when the instance #call method is not defined" do
      it "raises a NoMethodError" do
        expect { described_class.call }.to raise_error(NoMethodError)
      end
    end

    context "when the instance #call method is defined" do
      subject(:test_query) do
        Class.new(ApplicationQuery) do
          def call
            [1, 2, 3]
          end
        end
      end

      it "forwards the call to the instance method #call" do
        expect(test_query.call).to eq([1, 2, 3])
      end
    end

    context "when provided with a 'params' hash" do
      subject(:test_query) do
        Class.new(ApplicationQuery) do
          def call
            params[:number]
          end
        end
      end

      let(:params) { { number: 42 } }

      it "passes the params to the instance initializer and can be used within #call" do
        expect(test_query.call(params:)).to eq(42)
      end
    end
  end
end
