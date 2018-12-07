class AddBountyToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :bounty, :integer, default: 0
    add_column :users, :bounty_claimed, :integer, default: 0
  end
end
