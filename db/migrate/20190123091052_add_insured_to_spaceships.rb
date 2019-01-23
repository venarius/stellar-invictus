class AddInsuredToSpaceships < ActiveRecord::Migration[5.2]
  def change
    add_column :spaceships, :insured, :boolean, default: false
  end
end
