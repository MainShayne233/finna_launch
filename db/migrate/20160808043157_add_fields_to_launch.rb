class AddFieldsToLaunch < ActiveRecord::Migration[5.0]
  def change
    rename_column :launches, :datetime, :date
    change_column :launches, :date, :string
    add_column :launches, :window, :string
    add_column :launches, :site, :string
    add_column :launches, :description, :string
  end
end
