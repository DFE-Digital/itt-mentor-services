require "rails_helper"

RSpec.describe PersonaDecorator do
  describe "#type_tag_colour" do
    context "when the persona is Anne" do
      it "returns purple" do
        expect(build(:persona, :anne).decorate.type_tag_colour).to eq("purple")
      end
    end

    context "when the persona is Patricia" do
      it "returns orange" do
        expect(build(:persona, :patricia).decorate.type_tag_colour).to eq(
          "orange",
        )
      end
    end

    context "when the persona is Mary" do
      it "returns yellow" do
        expect(build(:persona, :mary).decorate.type_tag_colour).to eq("yellow")
      end
    end

    context "when the persona is Colin" do
      it "returns blue" do
        expect(build(:persona, :colin).decorate.type_tag_colour).to eq("blue")
      end
    end

    context "when the persona is not listed in the decorator" do
      it "returns turquoise" do
        expect(build(:persona).decorate.type_tag_colour).to eq("turquoise")
      end
    end
  end
end
