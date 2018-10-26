class AddInWarpToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :in_warp, :boolean
  end
end
