class AddNpcTargetIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :npc_target_id, :integer
  end
end
