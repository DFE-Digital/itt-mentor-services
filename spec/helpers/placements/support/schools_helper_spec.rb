require "rails_helper"

RSpec.describe Placements::Support::SchoolsHelper do
  describe "#ofsted_field_args" do
    context "value is empty" do
      it "returns empty state and hint class" do
        value = ""
        expect(ofsted_field_args(value)).to match({ text: "Unknown", classes: "govuk-hint" })
      end
    end

    context "value is not empty" do
      it "returns just the text" do
        value = "Some value"
        expect(ofsted_field_args(value)).to match({ text: "Some value" })
      end
    end
  end

  describe "#details_field_args" do
    context "value is empty" do
      it "returns empty state and hint class" do
        value = ""
        expect(details_field_args(value)).to match({ text: "Not entered", classes: "govuk-hint" })
      end
    end

    context "value is not empty" do
      it "returns just the text" do
        value = "Some value"
        expect(details_field_args(value)).to match({ text: "Some value" })
      end
    end
  end
end
