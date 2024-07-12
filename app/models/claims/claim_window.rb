# == Schema Information
#
# Table name: claim_windows
#
#  id               :uuid             not null, primary key
#  discarded_at     :date
#  ends_on          :date
#  starts_on        :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  academic_year_id :uuid             not null
#
# Indexes
#
#  index_claim_windows_on_academic_year_id  (academic_year_id)
#  index_claim_windows_on_discarded_at      (discarded_at)
#
# Foreign Keys
#
#  fk_rails_...  (academic_year_id => academic_years.id)
#
class Claims::ClaimWindow < ApplicationRecord
  include Discard::Model

  default_scope -> { kept }

  belongs_to :academic_year

  validates :starts_on, presence: true
  validates :ends_on, presence: true, comparison: { greater_than_or_equal_to: :starts_on }

  validate :does_not_overlap_with_another_claim_window

  delegate :name, to: :academic_year, prefix: true

  def self.find_by_date(date)
    find_by(starts_on: ...date, ends_on: date..)
  end

  def self.current
    find_by_date(Date.current)
  end

  private

  def does_not_overlap_with_another_claim_window
    overlapping_claim_window = Claims::ClaimWindow.where.not(id:).find_by("starts_on <= ? AND ends_on >= ?", ends_on, starts_on)

    return if overlapping_claim_window.blank?

    errors.add(:base, "Claim window overlaps with an existing claim window - #{I18n.l(overlapping_claim_window.starts_on, format: :long)} to #{I18n.l(overlapping_claim_window.ends_on, format: :long)}")
  end
end
