# frozen_string_literal: true

class PersonasController < ApplicationController
  def index
    if current_service.present?
      @personas = Persona.public_send(current_service).decorate
    else
      redirect_to :not_found
    end
  end
end
