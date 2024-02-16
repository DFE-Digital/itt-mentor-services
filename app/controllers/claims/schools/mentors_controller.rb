class Claims::Schools::MentorsController < ApplicationController
  include Claims::BelongsToSchool

  def index
    @pagy, @mentors = pagy(@school.mentors.order(:first_name, :last_name))
  end
end
