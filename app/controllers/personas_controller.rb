# frozen_string_literal: true

class PersonasController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index
    @personas = User.where(email: PERSONA_EMAILS)
      .where(type: ["#{current_service.to_s.titleize}::User",
                    "#{current_service.to_s.titleize}::SupportUser"])
      .order(:created_at)
  end
end
