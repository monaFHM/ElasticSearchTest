class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :title
      t.string :content
      t.integer :location_id
      t.string :publisher_id
      t.date :published_date
      t.integer :category_id

      t.timestamps
    end
  end
end
