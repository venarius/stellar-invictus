class AddEquippedToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :equipped, :boolean, default: false
  end
end
