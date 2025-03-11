class CreatePlants < ActiveRecord::Migration[7.1]
  def change
    create_table :plants do |t|
      t.string :name
      t.integer :price
      t.text :description
      t.integer :stock

      t.timestamps
    end
  end
end
