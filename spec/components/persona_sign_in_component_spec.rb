require "rails_helper"

RSpec.describe PersonaSignInComponent, type: :component do
  it "renders a form for persona sign in" do
    persona = create(:placements_support_user)
    render_inline(described_class.new(persona))

    expect(page).to have_button("Sign in as #{persona.first_name}")
  end

  describe "#type_tag_colour" do
    subject(:type_tag_colour) { described_class.new(persona).type_tag_colour }

    context "when persona is Anne" do
      let(:persona) { create(:placements_user, :anne) }

      it "returns purple" do
        expect(type_tag_colour).to eq("purple")
      end
    end

    context "when persona is Patricia" do
      let(:persona) { create(:placements_user, :patricia) }

      it "returns orange" do
        expect(type_tag_colour).to eq("orange")
      end
    end

    context "when persona is Mary" do
      let(:persona) { create(:placements_user, :mary) }

      it "returns orange" do
        expect(type_tag_colour).to eq("yellow")
      end
    end

    context "when persona is Colin" do
      let(:persona) { create(:placements_support_user, :colin) }

      it "returns orange" do
        expect(type_tag_colour).to eq("blue")
      end
    end

    context "when persona is a random user" do
      let(:persona) { create(:placements_user) }

      it "returns orange" do
        expect(type_tag_colour).to eq("turquoise")
      end
    end
  end
end
