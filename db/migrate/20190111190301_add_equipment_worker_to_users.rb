class AddEquipmentWorkerToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :equipment_worker, :boolean, default: false
  end
end
