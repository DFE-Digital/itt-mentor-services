require "rails_helper"

RSpec.describe UniqueIdentifierValidator do
  subject(:record) { Validatable.new }

  before do
    validatable_class = Class.new do
      include ActiveModel::Validations

      attr_accessor :urn, :vendor_number

      validates_with UniqueIdentifierValidator

      def initialize(urn: nil, vendor_number: nil)
        @urn = urn
        @vendor_number = vendor_number
      end
    end

    stub_const("Validatable", validatable_class)
  end

  context "when both urn and vendor_number are blank" do
    it "adds an error to the base" do
      record.valid?

      expect(record.errors[:base]).to include("A unique reference number (URN) or vendor number is required")
    end
  end

  context "when urn is present" do
    before do
      record.urn = "123456789"
    end

    it "does not add an error" do
      record.valid?

      expect(record.errors[:base]).to be_empty
    end
  end

  context "when vendor_number is present" do
    before do
      record.vendor_number = "987654321"
    end

    it "does not add an error" do
      record.valid?

      expect(record.errors[:base]).to be_empty
    end
  end
end
