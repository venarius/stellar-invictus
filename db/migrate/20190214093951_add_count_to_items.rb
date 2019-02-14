class AddCountToItems < ActiveRecord::Migration[5.2]
  def change
    add_column :items, :count, :integer, default: 1
  end
end
