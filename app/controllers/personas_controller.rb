# frozen_string_literal: true

class PersonasController < ApplicationController
  def index
    @personas = Persona.all.order(:first_name)
  end
end
