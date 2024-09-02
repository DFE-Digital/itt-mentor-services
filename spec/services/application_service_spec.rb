require "rails_helper"

describe ApplicationService do
  describe ".call" do
    it "raises a NoMethodError" do
      expect { described_class.call }.to raise_error(NoMethodError)
    end
  end

  describe "extending the ApplicationService" do
    let(:service_class) do
      Class.new(described_class) do
        def call
          "Hello, world!"
        end
      end
    end

    describe ".call" do
      it "returns 'Hello, world!'" do
        expect(service_class.call).to eq("Hello, world!")
      end
    end
  end
end
