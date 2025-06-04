# == Schema Information
#
# Table name: placements
#
#  id               :uuid             not null, primary key
#  school_id        :uuid
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  provider_id      :uuid
#  subject_id       :uuid
#  year_group       :enum
#  academic_year_id :uuid             not null
#  creator_type     :string
#  creator_id       :uuid
#
# Indexes
#
#  index_placements_on_academic_year_id  (academic_year_id)
#  index_placements_on_creator           (creator_type,creator_id)
#  index_placements_on_provider_id       (provider_id)
#  index_placements_on_school_id         (school_id)
#  index_placements_on_subject_id        (subject_id)
#  index_placements_on_year_group        (year_group)
#

class Placement < ApplicationRecord
  has_many :placement_mentor_joins, dependent: :destroy
  has_many :mentors, through: :placement_mentor_joins, class_name: "Placements::Mentor"

  has_many :placement_additional_subjects, class_name: "Placements::PlacementAdditionalSubject", dependent: :destroy
  has_many :additional_subjects, through: :placement_additional_subjects, source: :subject
  has_many :placement_windows, class_name: "Placements::PlacementWindow", dependent: :destroy
  has_many :terms, class_name: "Placements::Term", through: :placement_windows

  belongs_to :academic_year, class_name: "Placements::AcademicYear"
  belongs_to :school, class_name: "Placements::School"
  belongs_to :provider, class_name: "::Provider", optional: true
  belongs_to :subject, class_name: "::Subject", optional: true
  belongs_to :creator, optional: true, polymorphic: true
  belongs_to :key_stage, class_name: "Placements::KeyStage", optional: true

  accepts_nested_attributes_for :mentors, allow_destroy: true

  attribute :year_group, :string
  enum :year_group, {
    nursery: "nursery",
    reception: "reception",
    year_1: "year_1",
    year_2: "year_2",
    year_3: "year_3",
    year_4: "year_4",
    year_5: "year_5",
    year_6: "year_6",
    mixed_year_groups: "mixed_year_groups",
  }, validate: { allow_nil: true }

  validates :school, presence: true
  validates :subject, presence: true, if: -> { !send_specific }
  validates :key_stage, presence: true, if: -> { send_specific }

  delegate :name, to: :provider, prefix: true, allow_nil: true
  delegate :has_child_subjects?, to: :subject, allow_nil: true, prefix: true

  scope :order_by_subject_school_name, -> { includes(:subject, :school).order("subjects.name", "schools.name") }
  scope :available_placements_for_academic_year, ->(academic_year) { where(provider: nil, academic_year:) }
  scope :unavailable_placements_for_academic_year, ->(academic_year) { where(academic_year:).where.not(provider: nil) }
  scope :send_placements_for_academic_year, ->(academic_year) { where(academic_year:, send_specific: true) }

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

  def last_placement_for_school?
    school.placements.where.not(id: id).none?
  end
end
