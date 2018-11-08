class AddMiningTargetIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :mining_target_id, :integer
  end
end
