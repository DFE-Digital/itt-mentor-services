require "rails_helper"

RSpec.describe ApplicationForm do
  describe "#persist" do
    it "returns true" do
      expect(described_class.new.persist).to eq(true)
    end
  end

  describe "#save" do
    context "when the form is valid" do
      it "returns true" do
        expect(described_class.new.save).to eq(true)
      end
    end

    context "when the form is invalid" do
      before do
        invalid_form = Class.new(ApplicationForm) do
          attr_accessor :name

          validates :name, presence: true
        end

        stub_const("InvalidForm", invalid_form)
      end

      it "returns false" do
        expect(InvalidForm.new(name: nil).save).to eq(false)
      end
    end
  end

  describe "#save!" do
    context "when the form is valid" do
      it "returns true" do
        expect(described_class.new.save!).to eq(true)
      end
    end

    context "when the form is invalid" do
      before do
        invalid_form = Class.new(ApplicationForm) do
          attr_accessor :name

          validates :name, presence: true
        end

        stub_const("InvalidForm", invalid_form)
      end

      it "raises an error" do
        expect { InvalidForm.new(name: nil).save! }.to raise_error(ActiveModel::ValidationError, "Validation failed: Name can't be blank")
      end
    end
  end
end
