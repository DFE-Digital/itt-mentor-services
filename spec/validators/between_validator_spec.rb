require "rails_helper"

RSpec.describe BetweenValidator do
  subject(:validatable) do
    Validatable.new(value:)
  end

  before do
    validatable_class = Class.new do
      include ActiveModel::Validations

      attr_accessor :value

      validates :value, between: { min: 1, max: 10 }

      def initialize(value:)
        @value = value
      end
    end

    stub_const("Validatable", validatable_class)
  end

  context "when given a value less than the 'min' option" do
    let(:value) { 0 }

    it do
      expect(validatable).to be_invalid
      expect(validatable.errors[:value]).to include("must be between 1 and 10")
    end
  end

  context "when given a value greater than the 'min' option and less than the 'max' option" do
    let(:value) { 5 }

    it { is_expected.to be_valid }
  end

  context "when given a value greater than the 'max' option" do
    let(:value) { 11 }

    it do
      expect(validatable).to be_invalid
      expect(validatable.errors[:value]).to include("must be between 1 and 10")
    end
  end

  context "when given a 'nil' value" do
    let(:value) { nil }

    it do
      expect(validatable).to be_invalid
      expect(validatable.errors[:value]).to include("must be between 1 and 10")
    end
  end

  context "when given a symbol for the 'min' and 'max' options" do
    subject(:validatable) do
      Validatable.new(value:)
    end

    before do
      validatable_class = Class.new do
        include ActiveModel::Validations

        attr_accessor :value

        validates :value, between: { min: :min, max: :max }

        def initialize(value:)
          @value = value
        end

        def min
          5
        end

        def max
          min + 5
        end
      end

      stub_const("Validatable", validatable_class)
    end

    context "when given a value less than the 'min' option" do
      let(:value) { 0 }

      it do
        expect(validatable).to be_invalid
        expect(validatable.errors[:value]).to include("must be between 5 and 10")
      end
    end

    context "when given a value greater than the 'min' option and less than the 'max' option" do
      let(:value) { 7 }

      it { is_expected.to be_valid }
    end

    context "when given a value greater than the 'max' option" do
      let(:value) { 11 }

      it do
        expect(validatable).to be_invalid
        expect(validatable.errors[:value]).to include("must be between 5 and 10")
      end
    end

    context "when given a 'nil' value" do
      let(:value) { nil }

      it do
        expect(validatable).to be_invalid
        expect(validatable.errors[:value]).to include("must be between 5 and 10")
      end
    end
  end
end
