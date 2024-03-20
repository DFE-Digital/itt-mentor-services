RSpec.shared_examples "a service object" do
  describe "#call" do
    context "when .call is called on the class" do
      let(:described_class_instance) { instance_double(described_class) }

      before do
        allow(described_class).to receive(:new).and_return(described_class_instance)
        allow(described_class_instance).to receive(:call)
      end

      it "calls #call method on an instance of the class" do
        service_params = defined?(params) ? params : {}

        described_class.call(**service_params)
        expect(described_class_instance).to have_received(:call).once
      end
    end
  end
end
