class CreateArfGiBills < ActiveRecord::Migration[4.2]
  def change
    create_table :arf_gi_bills do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.integer :gibill

      # Not used in building DataCsv, but used in exporting source csv
      t.integer :total_paid
      t.string :institution
      t.integer :station
      t.integer :count_of_adv_pay_students
      t.integer :count_of_reg_students

      t.timestamps null: false
      t.index :facility_code, unique: true
    end
  end
end
