class CreateDownloadAccessTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :download_access_tokens, id: :uuid do |t|
      t.references :activity_record, polymorphic: true, null: false, type: :uuid
      t.string :email_address, null: false
      t.datetime :downloaded_at
      t.timestamps
    end
  end
end
