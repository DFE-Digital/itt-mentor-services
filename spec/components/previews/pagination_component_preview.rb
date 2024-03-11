class PaginationComponentPreview < ApplicationComponentPreview
  def default
    render PaginationComponent.new(pagy: Pagy.new(count: 100, page: 2))
  end
end
