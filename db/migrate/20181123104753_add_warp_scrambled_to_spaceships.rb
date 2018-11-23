class AddWarpScrambledToSpaceships < ActiveRecord::Migration[5.2]
  def change
    add_column :spaceships, :warp_scrambled, :boolean, default: false
    add_column :spaceships, :warp_target_id, :integer
  end
end
