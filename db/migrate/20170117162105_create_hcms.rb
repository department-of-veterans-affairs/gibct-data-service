class CreateHcms < ActiveRecord::Migration
  def change
    create_table :hcms do |t|
      # Used in the building of DataCsv
      t.string :ope, null: false
      t.string :ope6, null: false
      t.string :institution
      t.string :city
      t.string :state
      t.string :country
      t.string :institution_type

      t.string :hcm_type
      t.string :hcm_reason

      # Not used in building DataCsv, but used in exporting source csv
      t.timestamps null: false

      t.index :ope
    end
  end
end
