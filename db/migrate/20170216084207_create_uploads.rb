class CreateUploads < ActiveRecord::Migration
  def change
    create_table :uploads do |t|
      t.belongs_to :user, null: false

      t.string :csv, null: false
      t.string :csv_type, null: false
      t.string :comment
      t.boolean :ok, null: false, default: false

      t.timestamps null: false
      t.index :user_id
      t.index :csv_type
      t.index :updated_at
    end
  end
end
