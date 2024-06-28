class Placements::BaseStep
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_reader :wizard

  def initialize(wizard:, attributes:)
    @wizard = wizard
    super(attributes)
  end

  def to_partial_path
    self.class.name.demodulize.underscore
  end
end
