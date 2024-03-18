RSpec.shared_examples "a service object" do
  describe "#call" do
    context "when the #call method is not implemented" do
      let(:test_class) { Class.new { include ServicePattern } }

      it "raises a NotImplementedError" do
        expect { test_class.call }.to raise_error(NoMethodError, "#call must be implemented")
      end
    end

    context "when the #call method is implemented" do
      before do
        allow(described_class).to receive(:call).and_return(true)
      end

      it "calls the service logic" do
        described_class.call
        expect(described_class).to have_received(:call).once
      end
    end
  end
end
