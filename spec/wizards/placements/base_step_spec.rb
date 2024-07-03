require "rails_helper"

# A mock wizard so we can test the base class
require_relative "./burger_order_wizard_mock"

RSpec.describe Placements::BaseStep, type: :model do
  subject(:step) { BurgerOrderWizard::ChooseBurgerStep.new(wizard:, attributes:) }

  let(:wizard) { instance_double(BurgerOrderWizard) }
  let(:attributes) { nil }

  it "behaves like an ActiveModel object" do
    expect(step).to be_a(ActiveModel::Model)
    expect(step).to be_a(ActiveModel::Attributes)
  end

  describe "rendering in a view" do
    it "responds to #to_partial_path" do
      expect(step.to_partial_path).to eq("placements/wizards/instance_verifying_double/choose_burger_step")
    end
  end
end
