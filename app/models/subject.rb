# == Schema Information
#
# Table name: subjects
#
#  id                :uuid             not null, primary key
#  code              :string
#  name              :string           not null
#  subject_area      :enum
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  parent_subject_id :uuid
#
# Indexes
#
#  index_subjects_on_parent_subject_id  (parent_subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (parent_subject_id => subjects.id)
#
class Subject < ApplicationRecord
  belongs_to :parent_subject, class_name: "Subject", optional: true

  has_many :child_subjects, class_name: "Subject", foreign_key: :parent_subject_id, dependent: :destroy
  has_many :placements, dependent: :restrict_with_exception

  enum :subject_area,
       { primary: "primary", secondary: "secondary" },
       validate: true

  validates :subject_area, :name, presence: true

  scope :order_by_name, -> { order(:name) }
  scope :parent_subjects, -> { where(parent_subject_id: nil).order_by_name }

  def has_child_subjects?
    child_subjects.exists?
  end

  def name_as_attribute
    name.parameterize(separator: "_").to_sym
  end
end
