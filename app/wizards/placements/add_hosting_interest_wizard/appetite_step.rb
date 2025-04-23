class Placements::AddHostingInterestWizard::AppetiteStep < BaseStep
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
    appetites = Placements::HostingInterest.appetites.keys
    appetites.delete("already_organised") # Removed for concept testing
    @placement_appetites ||= appetites
  end

  private

  def locale_path
    ".wizards.placements.add_hosting_interest_wizard.appetite_step"
  end
end
