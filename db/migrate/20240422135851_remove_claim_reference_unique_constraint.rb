class RemoveClaimReferenceUniqueConstraint < ActiveRecord::Migration[7.1]
  def up
    if ActiveRecord::Base.connection.index_exists?(:claims, :reference)
      remove_index(:claims, :reference, unique: true)
    end
  end

  def down
    # Do nothing, we can't really re-apply the index as it might fail
  end
end
