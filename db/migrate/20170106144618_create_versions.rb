class CreateVersions < ActiveRecord::Migration[4.2]
  def change
    create_table :versions do |t|
      t.belongs_to :user, null: false

      t.integer :number, null: false
      t.boolean :production, default: false, null: false

      t.timestamps null: false
      t.index :user_id
      t.index :number
    end
  end
end
