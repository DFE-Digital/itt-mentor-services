require "rails_helper"

RSpec.describe SummaryListHelper do
  describe "#summary_row_value" do
    context "when given a value" do
      it "returns a hash containing the value" do
        expect(
          summary_row_value(value: "Some text"),
        ).to eq({ text: "Some text" })
      end
    end

    context "when no value is given" do
      context "when not given an empty text" do
        it "returns a hash containing 'Not entered', and classes 'govuk-hint'" do
          expect(
            summary_row_value,
          ).to eq({ text: "Not entered", classes: "govuk-hint" })
        end
      end

      context "when given an empty text" do
        it "returns a hash containing the given empty text, and classes 'govuk-hint'" do
          expect(
            summary_row_value(empty_text: "This value was not given"),
          ).to eq({ text: "This value was not given", classes: "govuk-hint" })
        end
      end
    end
  end
end
