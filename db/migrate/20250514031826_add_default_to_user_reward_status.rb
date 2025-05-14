class AddDefaultToUserRewardStatus < ActiveRecord::Migration[7.1]
  def change
     change_column_default :user_rewards, :status, from: nil, to: 'claimed'
  end
end
