class AddApiUploads < ActiveRecord::Migration[5.2]
  def change
    create_table :api_uploads do |t|
      t.belongs_to :user, null: false

      t.string :api, null: false
      t.string :csv_type, null: false
      t.string :comment
      t.boolean :ok, null: false, default: false
      t.timestamp :completed_at

      t.timestamps null: false
      t.index :csv_type
      t.index :updated_at
      t.index :completed_at

    end
  end
end
