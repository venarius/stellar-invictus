class AddBannedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :banned, :boolean
    add_column :users, :banned_until, :datetime
    add_column :users, :banreason, :string
  end
end
