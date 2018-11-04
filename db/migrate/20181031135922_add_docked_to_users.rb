class AddDockedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :docked, :boolean, default: false
  end
end
