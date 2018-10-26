class AddLocationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :location, foreign_key: true
  end
end
