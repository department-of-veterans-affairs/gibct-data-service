class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.integer :number, index: true, null: false
      t.datetime :approved_on, index: true, default: nil, null: true
      t.string :by, index: true

      t.timestamps null: false
    end
  end
end
