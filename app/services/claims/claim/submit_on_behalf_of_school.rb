class Claims::Claim::SubmitOnBehalfOfSchool < ApplicationService
  include Claims::Claim::Referencable

  STATUSES = %i[submitted paid].freeze

  def initialize(claim:, support_user:, status: :submitted, paid_to_la: nil, date_paid: nil)
    @claim = claim
    @support_user = support_user
    @status = status.to_sym
    @paid_to_la = paid_to_la
    @date_paid = date_paid
  end

  def call
    validate_arguments!

    claim.status = status
    claim.submitted_at = Time.current
    claim.submitted_by = support_user
    claim.reference = generate_reference if claim.reference.nil?
    mark_as_paid if paid?
    claim.save!
  end

  private

  attr_reader :claim, :support_user, :status, :paid_to_la, :date_paid

  def paid?
    status == :paid
  end

  # The school is not emailed about claims created on its behalf, so the paid
  # notification is recorded as already sent.
  def mark_as_paid
    claim.date_paid = date_paid
    claim.paid_to_la = paid_to_la
    claim.paid_notification_sent_at = Time.current
  end

  def validate_arguments!
    raise ArgumentError, "status must be submitted or paid" unless STATUSES.include?(status)
    return unless paid?

    raise ArgumentError, "date_paid is required for a paid claim" if date_paid.nil?
    raise ArgumentError, "paid_to_la is required for a paid claim" if paid_to_la.nil?
  end
end
