class CreateSec702s < ActiveRecord::Migration[4.2]
  def change
    create_table :sec702s do |t|
     # Used in the building of DataCsv
      t.string :state, null: false
      t.boolean :sec_702

      # Not used in building DataCsv, but used in exporting source csv
      t.string :state_full_name
      t.timestamps null: false

      t.index :state, unique: true
    end
  end
end
