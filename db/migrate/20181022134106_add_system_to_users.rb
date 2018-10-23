class AddSystemToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :system, foreign_key: true
  end
end
