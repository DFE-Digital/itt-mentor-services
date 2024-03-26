class Claims::FeedbackForm < ApplicationForm
  attr_accessor :option, :improve_comment, :email, :full_name

  validates :option, presence: { message: "Select how you feel about this service" }
  validates :improve_comment, presence: { message: "Enter details about how we could improve this service" }

  validate :validate_improve_comment_length

  private

  def validate_improve_comment_length
    if improve_comment.present? && improve_comment.split.length > 200
      errors.add(:improve_comment, "Details must be 200 words or fewer")
    end
  end
end
