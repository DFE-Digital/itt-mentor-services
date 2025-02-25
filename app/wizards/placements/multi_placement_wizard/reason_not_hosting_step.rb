class Placements::MultiPlacementWizard::ReasonNotHostingStep < BaseStep
  attribute :reasons_not_hosting, default: []

  validates :reasons_not_hosting, presence: true

  def reason_options
    options = Struct.new(:name, :value)
    reasons.map do |a_reason|
      options.new(name: a_reason, value: a_reason)
    end
  end

  def reasons_not_hosting=(value)
    super normalised_reasons_not_hosting(value)
  end

  private

  def normalised_reasons_not_hosting(selected_reasons)
    return [] if selected_reasons.blank?

    selected_reasons.reject(&:blank?)
  end

  def reasons
    [
      I18n.t("#{locale_path}.options.not_enough_trained_mentors"),
      I18n.t("#{locale_path}.options.number_of_pupils_with_send_needs"),
      I18n.t("#{locale_path}.options.working_to_improve_our_ofsted_rating"),
    ]
  end

  def locale_path
    ".wizards.placements.multi_placement_wizard.reason_not_hosting_step"
  end
end
