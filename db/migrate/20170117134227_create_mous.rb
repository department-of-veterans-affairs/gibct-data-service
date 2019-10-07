class CreateMous < ActiveRecord::Migration[4.2]
  def change
    create_table :mous do |t|
      # Used in the building of DataCsv
      t.string :ope, null: false
      t.string :ope6, null: false

      t.string :status
      t.boolean :dodmou
      t.boolean :dod_status

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.string :trade_name
      t.string :city
      t.string :state
      t.string :institution_type
      t.string :approval_date
      t.timestamps null: false

      t.index :ope
      t.index :ope6
    end
  end
end
