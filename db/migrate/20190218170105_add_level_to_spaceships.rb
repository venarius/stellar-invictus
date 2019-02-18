class AddLevelToSpaceships < ActiveRecord::Migration[5.2]
  def change
    add_column :spaceships, :level, :integer, default: 0
  end
end
