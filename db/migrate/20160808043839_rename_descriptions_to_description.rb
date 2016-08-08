class RenameDescriptionsToDescription < ActiveRecord::Migration[5.0]
  def change
    rename_column :launches, :descriptions, :description
  end
end
