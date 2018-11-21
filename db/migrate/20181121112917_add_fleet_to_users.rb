class AddFleetToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :fleet, foreign_key: true
  end
end
