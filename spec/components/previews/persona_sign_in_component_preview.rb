require "factory_bot"

class PersonaSignInComponentPreview < ViewComponent::Preview
  def user_anne
    persona = FactoryBot.build(:placements_support_user, :anne)
    render_with_template(
      template: "persona_sign_in_component_preview/default",
      locals: { persona: },
    )
  end

  def user_mary
    persona = FactoryBot.build(:placements_user, :mary)
    render_with_template(
      template: "persona_sign_in_component_preview/default",
      locals: { persona: },
    )
  end

  def user_patricia
    persona = FactoryBot.build(:placements_user, :patricia)
    render_with_template(
      template: "persona_sign_in_component_preview/default",
      locals: { persona: },
    )
  end

  def support_user_colin
    persona = FactoryBot.build(:placements_support_user, :colin)
    render_with_template(
      template: "persona_sign_in_component_preview/default",
      locals: { persona: },
    )
  end
end
