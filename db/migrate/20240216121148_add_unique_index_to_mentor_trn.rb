class AddUniqueIndexToMentorTrn < ActiveRecord::Migration[7.1]
  def change
    add_index :mentors, :trn, unique: true
  end
end
