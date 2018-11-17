class AddLastActionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_action, :datetime
  end
end
