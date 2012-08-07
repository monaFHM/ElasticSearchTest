class RemoveLatFromLocation < ActiveRecord::Migration
  def up
    remove_column :locations, :lat
  end

  def down
    add_column :locations, :lat, :integer
  end
end
