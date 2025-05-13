class CreateUserRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :user_rewards do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reward, null: false, foreign_key: true
      t.string :status, null: false
      t.datetime :redeemed_at
      t.timestamps
    end

    add_index :user_rewards, %i[user_id reward_id]
  end
end
