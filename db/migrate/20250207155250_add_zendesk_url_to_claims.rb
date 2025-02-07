class AddZendeskUrlToClaims < ActiveRecord::Migration[7.2]
  def change
    add_column :claims, :zendesk_url, :string
  end
end
