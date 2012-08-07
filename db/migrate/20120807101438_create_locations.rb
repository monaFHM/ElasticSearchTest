class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.string :name
      t.integer :lat
      t.integer :lng

      t.timestamps
    end
  end
end
