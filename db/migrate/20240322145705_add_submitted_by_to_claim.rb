class AddSubmittedByToClaim < ActiveRecord::Migration[7.1]
  def change
    add_reference :claims, :submitted_by, polymorphic: true, type: :uuid
  end
end
