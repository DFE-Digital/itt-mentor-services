class ReplaceUserIndexesWithDiscardedCompositeIndex < ActiveRecord::Migration[7.1]
  def change
    remove_index :users, :discarded_at
    add_index :users, %i[type discarded_at email]
  end
end
