class AddMissionToItems < ActiveRecord::Migration[5.2]
  def change
    add_reference :items, :mission, foreign_key: true
  end
end
