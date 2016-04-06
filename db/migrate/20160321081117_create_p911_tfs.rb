class CreateP911Tfs < ActiveRecord::Migration
  def change
    create_table :p911_tfs do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.float :p911_tuition_fees, null: false
      t.integer :p911_recipients, null: false

      t.timestamps null: false

      t.index :facility_code, unique: true
      t.index :institution
    end
  end
end
