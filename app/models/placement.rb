# == Schema Information
#
# Table name: placements
#
#  id          :uuid             not null, primary key
#  year_group  :enum
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  provider_id :uuid
#  school_id   :uuid
#  subject_id  :uuid
#
# Indexes
#
#  index_placements_on_provider_id  (provider_id)
#  index_placements_on_school_id    (school_id)
#  index_placements_on_subject_id   (subject_id)
#  index_placements_on_year_group   (year_group)
#
# Foreign Keys
#
#  fk_rails_...  (provider_id => providers.id)
#  fk_rails_...  (school_id => schools.id)
#  fk_rails_...  (subject_id => subjects.id)
#
class Placement < ApplicationRecord
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_additional_subjects, class_name: "Placements::PlacementAdditionalSubject", dependent: :destroy
  has_many :additional_subjects, through: :placement_additional_subjects, source: :subject

  belongs_to :school, class_name: "Placements::School"
  belongs_to :provider, optional: true, class_name: "::Provider"
  belongs_to :subject, class_name: "::Subject"

  accepts_nested_attributes_for :mentors, allow_destroy: true

  attribute :year_group, :string
  enum :year_group, {
    year_1: "year_1",
    year_2: "year_2",
    year_3: "year_3",
    year_4: "year_4",
    year_5: "year_5",
    year_6: "year_6",
  }, validate: { allow_nil: true }

  validates :school, presence: true

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :has_child_subjects?, to: :subject, allow_nil: true, prefix: true

  scope :order_by_subject_school_name, -> { includes(:subject, :school).order("subjects.name", "schools.name") }

  # This method is used to order placement, after the schools have been ordered by distance.
  # As distance is not an attribute of school, and is given to us by the Geocoder gem.
  def self.order_by_school_ids(school_ids)
    t = arel_table
    condition = Arel::Nodes::Case.new(t[:school_id])
    school_ids.each_with_index do |school_id, index|
      condition.when(school_id).then(index)
    end
    order(condition)
  end

  def self.year_groups_as_options
    year_groups.map do |_, value|
      OpenStruct.new value:, name: I18n.t("placements.schools.placements.year_groups.#{value}"),
                     description: I18n.t("placements.schools.placements.year_groups.#{value}_description")
    end
  end
end
