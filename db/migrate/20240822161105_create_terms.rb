class CreateTerms < ActiveRecord::Migration[7.1]
  def change
    create_table :terms, id: :uuid do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
