class AddUniqueIndexToBankHolidaysDate < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :bank_holidays, :date, unique: true, if_not_exists: true, algorithm: :concurrently
  end
end
