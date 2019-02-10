class AddCustomNameToSpaceships < ActiveRecord::Migration[5.2]
  def change
    add_column :spaceships, :custom_name, :string
  end
end
