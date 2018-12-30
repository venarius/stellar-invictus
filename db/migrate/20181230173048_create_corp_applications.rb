class CreateCorpApplications < ActiveRecord::Migration[5.2]
  def change
    create_table :corp_applications do |t|
      t.references :user, foreign_key: true
      t.references :corporation, foreign_key: true
      t.text :application_text

      t.timestamps
    end
  end
end
