class RemoveLngFromLocation < ActiveRecord::Migration
  def up
    remove_column :locations, :lng
  end

  def down
    add_column :locations, :lng, :integer
  end
end
