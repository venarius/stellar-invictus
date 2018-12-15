class AddNpcStateToNpcs < ActiveRecord::Migration[5.2]
  def change
    add_column :npcs, :npc_state, :integer
  end
end
