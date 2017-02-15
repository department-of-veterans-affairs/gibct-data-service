class CreateP911Tfs < ActiveRecord::Migration
  def change
    create_table :p911_tfs do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.float :p911_tuition_fees, null: false
      t.integer :p911_recipients, null: false

      # Not used in building DataCsv, but used in exporting source csv
      t.string :institution
      t.string :state
      t.string :country
      t.string :profit_status
      t.string :type_of_payment
      t.integer :number_of_payments
      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
