class RemoveNameUniqunessFromReward < ActiveRecord::Migration[7.1]
  def change
    remove_index :rewards, :name, unique: true
    add_index :rewards, :name
  end
end
