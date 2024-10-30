# A mock wizard implementation so we can test BaseWizard and BaseStep without
# being dependent on a particular wizard implementation within the app itself.
class BurgerOrderWizard < BaseWizard
  def define_steps
    # Define the wizard steps here
    add_step(ChooseBurgerStep)
    add_step(MealDealStep)
    add_step(ChooseSideStep) if steps[:meal_deal].meal_deal?
    add_step(ChooseDrinkStep) if steps[:meal_deal].meal_deal?
    add_step(CheckYourAnswersStep)
  end

  class ChooseBurgerStep < BaseStep
    attribute :burger
    validates :burger, inclusion: { in: %w[beef chicken veggie] }
  end

  class MealDealStep < BaseStep
    attribute :make_it_a_meal_deal
    validates :make_it_a_meal_deal, inclusion: { in: %w[yes no] }

    def meal_deal?
      make_it_a_meal_deal == "yes"
    end
  end

  class ChooseSideStep < BaseStep
    attribute :side
    validates :side, inclusion: { in: %w[fries salad coleslaw] }
  end

  class ChooseDrinkStep < BaseStep
    attribute :drink
    validates :drink, inclusion: { in: %w[cola water tea coffee] }
  end

  class CheckYourAnswersStep < BaseStep
    # This is a read-only step, so it doesn't have attributes.
  end
end
