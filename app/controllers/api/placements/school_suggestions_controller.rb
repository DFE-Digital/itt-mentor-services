class Api::Placements::SchoolSuggestionsController < Api::SchoolSuggestionsController
  private

  def model
    Placements::School
  end
end
