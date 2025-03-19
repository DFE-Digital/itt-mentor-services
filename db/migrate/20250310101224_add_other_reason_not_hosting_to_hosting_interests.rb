class AddOtherReasonNotHostingToHostingInterests < ActiveRecord::Migration[7.2]
  def change
    add_column :hosting_interests, :other_reason_not_hosting, :text
  end
end
