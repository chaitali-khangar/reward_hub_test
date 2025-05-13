class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.date :birthdate, null: false
      t.string :api_token, null: false
      t.string :country, null: false
      t.integer :total_points, default: 0, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :api_token, unique: true
  end
end
