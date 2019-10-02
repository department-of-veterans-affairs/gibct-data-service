class CreateStorages < ActiveRecord::Migration[4.2]
  def change
    create_table :storages do |t|
      t.belongs_to :user, null: false

      t.string :csv, null: false
      t.string :csv_type, null: false
      t.string :comment
      t.binary :data, null: false


      t.timestamps null: false
      t.index :user_id
      t.index :csv_type, unique: true
      t.index :updated_at

      t.timestamps null: false
    end
  end
end
