class RemoveClaimReferenceUniqueConstraint < ActiveRecord::Migration[7.1]
  def change
    remove_index(:claims, :reference, unique: true)
    add_index(:claims, :reference)
  end
end
