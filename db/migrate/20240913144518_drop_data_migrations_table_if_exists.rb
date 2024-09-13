class DropDataMigrationsTableIfExists < ActiveRecord::Migration[7.2]
  def up
    drop_table :data_migrations, if_exists: true
  end

  def down
    raise IrreversibleMigration
  end
end
