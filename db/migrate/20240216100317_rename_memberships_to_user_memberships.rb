class RenameMembershipsToUserMemberships < ActiveRecord::Migration[7.1]
  def change
    rename_table :memberships, :user_memberships
  end
end
