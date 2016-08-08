class CreateLaunches < ActiveRecord::Migration[5.0]
  def change
    create_table :launches do |t|
      t.date :datetime
      t.string :mission

      t.timestamps
    end
  end
end
