class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.belongs_to :user, null: false

      t.integer :version, null: false
      t.boolean :production, default: false, null: false

      t.timestamps null: false
      t.index :user_id, unique: true
      t.index :version
    end
  end
end
