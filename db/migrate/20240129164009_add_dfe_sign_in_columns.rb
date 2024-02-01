class AddDfESignInColumns < ActiveRecord::Migration[7.1]
  def change
    change_table(:users, bulk: true) do |t|
      t.column :dfe_sign_in_uid, :string
      t.column :last_signed_in_at, :datetime
    end
  end
end
