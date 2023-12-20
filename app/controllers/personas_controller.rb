# frozen_string_literal: true

class PersonasController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index]

  def index
    @personas = Persona.public_send(current_service).decorate
  end
end
