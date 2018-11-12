class AddIsAttackingToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :is_attacking, :boolean
  end
end
