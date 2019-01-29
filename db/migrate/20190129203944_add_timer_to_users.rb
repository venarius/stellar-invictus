class AddTimerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :logout_timer, :boolean, default: false
    add_column :users, :donator, :boolean, default: false
  end
end
