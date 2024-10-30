require "rails_helper"

# A mock wizard so we can test the base class
require_relative "./burger_order_wizard_mock"

RSpec.describe BaseWizard do
  subject(:wizard) { BurgerOrderWizard.new(state:, params:, current_step:) }

  let(:state) { {} }
  let(:params_data) { {} }
  let(:params) { ActionController::Parameters.new(params_data) }
  let(:current_step) { nil }

  describe "#steps" do
    it "is a Hash of Step objects" do
      expect(wizard.steps).to be_a(Hash)
      expect(wizard.steps.values).to all be_a(BaseStep)
    end

    it "holds steps in order of the user journey" do
      expect(wizard.steps.keys).to eq(%i[
        choose_burger
        meal_deal
        check_your_answers
      ])
    end

    context "when relevant steps have been completed" do
      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
          "meal_deal" => { "make_it_a_meal_deal" => "yes" },
        }
      end

      it "includes conditional steps" do
        expect(wizard.steps.keys).to eq(%i[
          choose_burger
          meal_deal
          choose_side
          choose_drink
          check_your_answers
        ])
      end
    end
  end

  describe "#step" do
    let(:current_step) { :meal_deal }

    it "returns the current step object" do
      expect(wizard.step).to eq(wizard.steps[:meal_deal])
      expect(wizard.step).to be_an_instance_of(BurgerOrderWizard::MealDealStep)
    end
  end

  describe "#first_step" do
    it "returns the name of the first step" do
      expect(wizard.first_step).to eq(:choose_burger)
    end
  end

  describe "#previous_step, #current_step, #next_step" do
    context "when current step is nil" do
      let(:current_step) { nil }

      it "defaults to the first step" do
        expect(wizard.previous_step).to be(false)
        expect(wizard.current_step).to eq(:choose_burger)
        expect(wizard.next_step).to eq(:meal_deal)
      end
    end

    context "when current step is the first step" do
      let(:current_step) { :choose_burger }

      it "returns the correct steps" do
        expect(wizard.previous_step).to be(false)
        expect(wizard.current_step).to eq(:choose_burger)
        expect(wizard.next_step).to eq(:meal_deal)
      end
    end

    context "when current step is :meal_deal" do
      let(:current_step) { :meal_deal }

      it "returns the correct steps" do
        expect(wizard.previous_step).to eq(:choose_burger)
        expect(wizard.current_step).to eq(:meal_deal)
        expect(wizard.next_step).to eq(:check_your_answers)
      end
    end

    context "when current step is the final step" do
      let(:current_step) { :check_your_answers }

      it "returns the correct steps" do
        expect(wizard.previous_step).to eq(:meal_deal)
        expect(wizard.current_step).to eq(:check_your_answers)
        expect(wizard.next_step).to be(false)
      end
    end

    context "when current step is a conditional step" do
      let(:current_step) { :choose_side }

      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
          "meal_deal" => { "make_it_a_meal_deal" => "yes" },
        }
      end

      it "returns the correct steps" do
        expect(wizard.previous_step).to eq(:meal_deal)
        expect(wizard.current_step).to eq(:choose_side)
        expect(wizard.next_step).to eq(:choose_drink)
      end
    end
  end

  context "when initialised with an unrecognised current_step" do
    let(:current_step) { :this_step_does_not_exist }

    it "raises an error" do
      expect { wizard }.to raise_error 'The step "this_step_does_not_exist" does not exist'
    end
  end

  describe "#add_step" do
    it "initialises the provided step class and adds it to #steps" do
      mock_step = instance_double(BurgerOrderWizard::ChooseBurgerStep)
      args = { wizard:, attributes: nil }
      allow(BurgerOrderWizard::ChooseBurgerStep).to receive(:new).with(args).and_return(mock_step)

      wizard.add_step(BurgerOrderWizard::ChooseBurgerStep)
      expect(wizard.steps[:choose_burger]).to be(mock_step)
    end

    context "when there is no state present" do
      it "does not set attributes" do
        wizard.add_step(BurgerOrderWizard::ChooseBurgerStep)
        expect(wizard.steps[:choose_burger]).to have_attributes(burger: nil)
      end
    end

    context "when there is existing state for the step" do
      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
        }
      end

      it "populates attributes from the state" do
        wizard.add_step(BurgerOrderWizard::ChooseBurgerStep)
        expect(wizard.steps[:choose_burger]).to have_attributes(burger: "beef")
      end
    end

    context "when a form submission has been received for the current step" do
      let(:params_data) do
        {
          "burger_order_wizard_choose_burger_step" => { "burger" => "chicken" },
        }
      end

      it "populates attributes from the controller params" do
        wizard.add_step(BurgerOrderWizard::ChooseBurgerStep)
        expect(wizard.steps[:choose_burger]).to have_attributes(burger: "chicken")
      end
    end

    context "when a form submission has been received and there is an existing state" do
      let(:params_data) do
        {
          "burger_order_wizard_choose_burger_step" => { "burger" => "chicken" },
        }
      end

      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
        }
      end

      it "uses the submitted form params in favour of the state" do
        wizard.add_step(BurgerOrderWizard::ChooseBurgerStep)
        expect(wizard.steps[:choose_burger]).to have_attributes(burger: "chicken")
      end
    end
  end

  describe "#reset_state" do
    let(:state) do
      {
        "choose_burger" => { "burger" => "beef" },
        "meal_deal" => { "make_it_a_meal_deal" => "yes" },
      }
    end

    it "clears the wizard state" do
      expect(wizard.state).to eq(state)
      wizard.reset_state
      expect(wizard.state).to eq({})
      expect(state).to eq({})
    end
  end

  describe "#save_step" do
    let(:current_step) { :choose_burger }
    let(:attributes) { {} }

    before do
      wizard.step.assign_attributes(attributes)
    end

    context "when the step is valid" do
      let(:attributes) { { burger: "veggie" } }

      it "returns true and updates the state" do
        expect(state).to eq({})

        expect(wizard.step.valid?).to be(true)
        expect(wizard.save_step).to be(true)

        expect(state).to eq({
          "choose_burger" => { "burger" => "veggie" },
        })
      end
    end

    context "when the step is invalid" do
      let(:attributes) { { burger: "pineapple" } }

      it "returns false and does not update the state" do
        expect(state).to eq({})

        expect(wizard.step.valid?).to be(false)
        expect(wizard.save_step).to be(false)

        expect(state).to eq({})
      end
    end
  end

  describe "#valid?" do
    subject { wizard.valid? }

    context "when all steps are valid" do
      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
          "meal_deal" => { "make_it_a_meal_deal" => "yes" },
          "choose_side" => { "side" => "fries" },
          "choose_drink" => { "drink" => "cola" },
        }
      end

      it { is_expected.to be(true) }
    end

    context "when there's an invalid step" do
      let(:state) do
        {
          "choose_burger" => { "burger" => "beef" },
          "meal_deal" => { "make_it_a_meal_deal" => "yes" },
          "choose_side" => { "side" => "bread roll" }, # invalid
          "choose_drink" => { "drink" => "cola" },
        }
      end

      it { is_expected.to be(false) }
    end
  end

  describe ".generate_state_key" do
    before do
      allow(SecureRandom).to receive(:uuid).and_call_original
      described_class.generate_state_key
    end

    it "returns a SecureRandom UUID" do
      expect(SecureRandom).to receive(:uuid).once.and_return("pineapple")
      expect(described_class.generate_state_key).to eq("pineapple")
    end
  end
end
