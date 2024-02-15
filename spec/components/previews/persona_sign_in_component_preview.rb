class PersonaSignInComponentPreview < ApplicationComponentPreview
  def user_anne
    persona = FactoryBot.build(:placements_support_user, :anne)
    render_with_template(template:, locals: { persona: })
  end

  def user_mary
    persona = FactoryBot.build(:placements_user, :mary)
    render_with_template(template:, locals: { persona: })
  end

  def user_patricia
    persona = FactoryBot.build(:placements_user, :patricia)
    render_with_template(template:, locals: { persona: })
  end

  def support_user_colin
    persona = FactoryBot.build(:placements_support_user, :colin)
    render_with_template(template:, locals: { persona: })
  end

  private

  def template
    "templates/persona_sign_in_component_preview"
  end
end
