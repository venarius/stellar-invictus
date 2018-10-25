class AddOnlineToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :online, :boolean
  end
end
