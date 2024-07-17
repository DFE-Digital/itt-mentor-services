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

  validate :is_not_longer_than_an_academic_year
  validate :does_not_start_in_the_past, on: :create
  validate :does_not_start_within_another_claim_window
  validate :does_not_end_in_the_past, on: :create
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

  private

  def is_not_longer_than_an_academic_year
    return if starts_on.blank? || ends_on.blank?

    if (ends_on - starts_on).to_i > 365
      errors.add(:base, :longer_than_academic_year)
    end
  end

  def does_not_start_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :starts_on AND ends_on >= :starts_on", starts_on:).exists?

    errors.add(:starts_on, :overlap)
  end

  def does_not_end_within_another_claim_window
    return unless Claims::ClaimWindow.where.not(id:).where("starts_on <= :ends_on AND ends_on >= :ends_on", ends_on:).exists?

    errors.add(:ends_on, :overlap)
  end

  def does_not_start_in_the_past
    errors.add(:starts_on, :past) if starts_on&.past?
  end

  def does_not_end_in_the_past
    errors.add(:ends_on, :past) if ends_on&.past?
  end
end
