# frozen_string_literal: true

class PersonasController < ApplicationController
  def index
    @personas = Persona.public_send(current_service).decorate
  end
end
