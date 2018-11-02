class AddActiveSpaceshipToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :active_spaceship_id, :integer
  end
end
