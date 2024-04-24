class AddReviewedByUserToClaims < ActiveRecord::Migration[7.1]
  def change
    add_column(:claims, :reviewed_by_user, :boolean, default: false)
  end
end
