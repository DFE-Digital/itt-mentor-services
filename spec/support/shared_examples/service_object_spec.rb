RSpec.shared_examples "a service object" do
  describe "#call" do
    context "when the #call method is not implemented" do
      let(:test_class) { Class.new { include ServicePattern } }

      it "raises a NotImplementedError" do
        expect { test_class.call }.to raise_error(NoMethodError, "#call must be implemented")
      end
    end

    context "when the #call method is implemented" do
      let(:test_class) do
        Class.new do
          include ServicePattern

          def call
            "called"
          end
        end
      end

      it "returns the expected value" do
        expect(test_class.call).to eq("called")
      end
    end
  end
end
