class AddMuteToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :muted, :boolean, default: false
  end
end
