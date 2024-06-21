class Placements::BaseStep
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :school

  validates :school, presence: true
end
