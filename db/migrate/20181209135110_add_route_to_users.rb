class AddRouteToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :route, :string, array: true, default: []
  end
end
