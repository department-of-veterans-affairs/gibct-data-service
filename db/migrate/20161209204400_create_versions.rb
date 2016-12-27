class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.belongs_to :user, index: true, null: false
      
      t.integer :version, index: true, null: false
      t.boolean :production, index: true, default: false, null: false

      t.timestamps null: false
    end
  end
end
