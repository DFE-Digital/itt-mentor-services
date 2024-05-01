class AddReviewedByUserToClaim < ActiveRecord::Migration[7.1]
  def change
    add_column(:claims, :reviewed, :boolean, default: false)
  end
end
