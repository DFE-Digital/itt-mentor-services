class PersonasController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index
    @personas = User.where(email: PERSONA_EMAILS)
      .where(type: persona_types)
      .order(:created_at)
  end

  private

  def persona_types
    if current_service == :claims
      %w[Claims::User Claims::ProviderUser Claims::SupportUser]
    else
      ["#{current_service.to_s.titleize}::User", "#{current_service.to_s.titleize}::SupportUser"]
    end
  end
end
