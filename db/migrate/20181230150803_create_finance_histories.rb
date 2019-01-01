class CreateFinanceHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :finance_histories do |t|
      t.references :user, foreign_key: true
      t.references :corporation, foreign_key: true
      t.integer :amount
      t.integer :action

      t.timestamps
    end
  end
end
