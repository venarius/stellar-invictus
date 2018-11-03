class AddTargetIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :target_id, :integer
  end
end
