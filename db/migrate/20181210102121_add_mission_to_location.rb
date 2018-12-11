class AddMissionToLocation < ActiveRecord::Migration[5.2]
  def change
    add_reference :locations, :mission, foreign_key: true
  end
end
