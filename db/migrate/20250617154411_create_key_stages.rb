class CreateKeyStages < ActiveRecord::Migration[8.0]
  def change
    create_table :key_stages, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
