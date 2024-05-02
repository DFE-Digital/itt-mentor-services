require "rails_helper"

RSpec.describe Placements::MarkdownHelper do
  describe "#render_markdown" do
    context "when given #" do
      it "returns h1 html tag, with class govuk-heading-l" do
        expect(render_markdown("#Hello#")).to eq("<h1 id=\"hello\" class=\"govuk-heading-l\">Hello</h1>")
      end
    end

    context "when given ##" do
      it "returns h2 html tag, with class govuk-heading-m" do
        expect(render_markdown("##Hello##")).to eq("<h2 id=\"hello\" class=\"govuk-heading-m\">Hello</h2>")
      end
    end

    context "when given ###" do
      it "returns h3 html tag, with class govuk-heading-s" do
        expect(render_markdown("###Hello###")).to eq("<h3 id=\"hello\" class=\"govuk-heading-s\">Hello</h3>")
      end
    end

    context "when given plain text" do
      it "returns p html tag" do
        expect(render_markdown("Hello")).to eq("<p class=\"govuk-body-m\">Hello</p>")
      end
    end

    context "when given - plain text" do
      it "returns ul and li html tags" do
        expect(render_markdown("- Hello")).to eq(
          "<ul class=\"govuk-list govuk-list--bullet\">\n  <li>Hello</li>\n\n</ul>",
        )
      end
    end
  end
end
