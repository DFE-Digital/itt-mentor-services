class CreateKeyStages < ActiveRecord::Migration[7.2]
  def change
    create_table :key_stages, id: :uuid do |t|
      t.string :name
      t.timestamps
    end
  end
end
