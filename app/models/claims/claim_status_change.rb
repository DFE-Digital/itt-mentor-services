class Claims::ClaimStatusChange < ApplicationRecord
  belongs_to :claim, class_name: "Claims::Claim", optional: true
  belongs_to :actor, polymorphic: true, optional: true
  belongs_to :source, polymorphic: true, optional: true

  validates :claim_id, :to_status, :actor_kind, :sequence, presence: true
  validates :actor_kind, inclusion: { in: %w[user system unknown] }
  validates :sequence, numericality: { only_integer: true, greater_than: 0 }
  validates :occurred_at, presence: true, unless: :imported?
  validate :live_attribution, unless: :imported?
  validate :status_changed

  scope :chronological, -> { order(Arel.sql("occurred_at ASC NULLS LAST"), :sequence, :id) }

  def readonly?
    persisted?
  end

  private

  def live_attribution
    case actor_kind
    when "user"
      errors.add(:actor, :blank) unless actor_id.present? && actor_type.present?
    when "system"
      errors.add(:system_operation, :blank) if system_operation.blank?
    else
      errors.add(:actor_kind, :invalid)
    end
  end

  def status_changed
    errors.add(:to_status, :invalid) if from_status.present? && from_status == to_status
  end
end
