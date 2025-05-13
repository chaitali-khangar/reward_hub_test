class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :rewards do |t|
      t.string :name, null: false
      t.text :description
      t.integer :points_req, null: false
      t.datetime :valid_from, null: false
      t.datetime :valid_until, null: false

      t.timestamps
    end
    add_index :rewards, :name, unique: true
  end
end
