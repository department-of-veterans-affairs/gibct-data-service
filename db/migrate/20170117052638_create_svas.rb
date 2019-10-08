class CreateSvas < ActiveRecord::Migration[4.2]
  def change
    create_table :svas do |t|
      # Used in the building of DataCsv
      t.string :cross
      t.string :student_veteran_link

      # Not used in building DataCsv, but used in exporting source csv
      t.integer :csv_id
      t.string :institution
      t.string :city
      t.string :state
      t.string :ipeds_code
      t.string :website
      t.string :sva_yes
      t.timestamps null: false

      t.index :cross
    end
  end
end
