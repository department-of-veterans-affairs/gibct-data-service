class CreateSec702Schools < ActiveRecord::Migration
  def change
    create_table :sec702_schools do |t|
      # Used in the building of DataCsv
      t.string :facility_code, null: false
      t.boolean :sec_702

      # Not used in building DataCsv, but used in exporting source csv
      t.timestamps null: false

      t.index :facility_code, unique: true
    end
  end
end
