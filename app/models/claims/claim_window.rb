# == Schema Information
#
# Table name: claim_windows
#
#  id               :uuid             not null, primary key
#  discarded_at     :date
#  ends_on          :date             not null
#  starts_on        :date             not null
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

  validate :does_not_start_within_another_claim_window
  validate :does_not_end_within_another_claim_window

  delegate :name, to: :academic_year, prefix: true
  delegate :past?, to: :ends_on
  delegate :future?, to: :starts_on

  def current?
    (starts_on..ends_on).cover?(Date.current)
  end

  def self.find_by_date(date)
    find_by(starts_on: ..date, ends_on: date..)
  end

  def self.current
    find_by_date(Date.current)
  end

  def self.previous
    where(ends_on: ..Date.current).order(ends_on: :desc).first
  end

  private

  def does_not_start_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :starts_on AND ends_on >= :starts_on", starts_on:).exists?

    errors.add(:starts_on, :overlap)
  end

  def does_not_end_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :ends_on AND ends_on >= :ends_on", ends_on:).exists?

    errors.add(:ends_on, :overlap)
  end
end
