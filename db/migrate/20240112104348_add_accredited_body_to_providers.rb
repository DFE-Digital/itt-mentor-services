class AddAccreditedBodyToProviders < ActiveRecord::Migration[7.1]
  def change
    add_column :providers, :accredited, :boolean, default: false
  end
end
