class Placement::PlacesAutocompleteComponent < ApplicationComponent
  def initialize(url:, label:, name:, clear_search_url:, caption: {},
                 filters: [], value: nil, classes: [], html_attributes: {})
    super(classes:, html_attributes:)

    @url = url
    @label = label
    @name = name
    @clear_search_url = clear_search_url
    @caption = caption
    @filters = filters
    @value = value
  end
end
