require "rails_helper"

RSpec.describe Placements::ButtonHelper do
  describe "#govuk_start_button_link_to" do
    it "returns a start button within a form" do
      expect(govuk_start_button_link_to(url: "")).to eq(
        "<form class=\"button_to\" method=\"post\" action=\"\">" \
        "<button class=\"govuk-button govuk-button--start \" role=\"button\" data-module=\"govuk-button\" draggable=\"false\" type=\"submit\">" \
        "Start now\n        <svg class=\"govuk-button__start-icon\" xmlns=\"http://www.w3.org/2000/svg\"" \
        " width=\"17.5\" height=\"19\" viewBox=\"0 0 33 40\" aria-hidden=\"true\" focusable=\"false\">\n" \
        "          <path fill=\"currentColor\" d=\"M0 0h13l20 20-20 20H0l20-20z\" />\n        </svg></button></form>",
      )
    end

    context "when given a body param" do
      it "returns a start button within a form, with custom text" do
        expect(
          govuk_start_button_link_to(body: "Custom start button", url: ""),
        ).to include("Custom start button")
      end
    end

    context "when given a url param" do
      it "returns a start button within a form, with custom text" do
        expect(
          govuk_start_button_link_to(url: "http://www.example.com"),
        ).to include("http://www.example.com")
      end
    end

    context "when given custom html options" do
      context "with custom class options" do
        it "appends custom classes to the start button" do
          expect(
            govuk_start_button_link_to(url: "", html_options: { class: "colour-me-red" }),
          ).to include("class=\"govuk-button govuk-button--start colour-me-red\"")
        end
      end

      context "with custom html attributes" do
        it "adds custom html options to the start button" do
          expect(
            govuk_start_button_link_to(url: "", html_options: { data_attribute: "i-am-clickable" }),
          ).to include("data_attribute=\"i-am-clickable\"")
        end
      end
    end
  end
end
