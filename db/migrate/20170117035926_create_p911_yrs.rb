class CreateP911Yrs < ActiveRecord::Migration[4.2]
  def change
    create_table :p911_yrs do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.float :p911_yellow_ribbon, null: false
      t.integer :p911_yr_recipients, null: false

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
