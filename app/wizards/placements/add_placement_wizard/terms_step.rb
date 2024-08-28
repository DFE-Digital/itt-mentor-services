class Placements::AddPlacementWizard::TermsStep < Placements::BaseStep
  attribute :term_ids, default: []

  validates :term_ids, presence: true

  def term_ids=(value)
    super normalised_term_ids(value)
  end

  def term_names
    return if term_ids == ANY_TERM

    terms.pluck(:name).to_sentence
  end

  def terms_for_selection
    Placements::Term.order_by_term
  end

  def terms
    return terms_for_selection.none if term_ids == ANY_TERM

    terms_for_selection.where(id: term_ids)
  end

  private

  ANY_TERM = %w[any_term].freeze

  def normalised_term_ids(term_ids)
    if term_ids.blank?
      []
    elsif term_ids.include?("any_term")
      ANY_TERM
    else
      terms_for_selection.where(id: term_ids).ids
    end
  end
end
