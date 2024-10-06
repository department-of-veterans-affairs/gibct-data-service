class CreateLceLicenseAndCerts < ActiveRecord::Migration[7.1]
  def change
    create_table :lce_license_and_certs do |t|
      t.string :name
      t.decimal :fee
      t.integer :institution_id

      t.timestamps
    end
  end
end
