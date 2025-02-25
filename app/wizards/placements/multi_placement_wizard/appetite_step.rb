class Placements::MultiPlacementWizard::AppetiteStep < BaseStep
  attribute :appetite

  validates :appetite, presence: true, inclusion: { in: ->(step) { step.placement_appetites } }

  def appetite_options
    options = Struct.new(:value, :name, :description)
    placement_appetites.map do |key|
      options.new(
        value: key,
        name: I18n.t(
          "#{locale_path}.options.#{key}.name",
        ),
        description: I18n.t(
          "#{locale_path}.options.#{key}.description",
        ),
      )
    end
  end

  def placement_appetites
    @placement_appetites ||= Placements::HostingInterest.appetites.keys
  end

  private

  def locale_path
    ".wizards.placements.multi_placement_wizard.appetite_step"
  end
end
