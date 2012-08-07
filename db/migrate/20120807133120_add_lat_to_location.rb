class AddLatToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :lat, :float
  end
end
