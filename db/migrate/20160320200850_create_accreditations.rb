class CreateAccreditations < ActiveRecord::Migration
  def change
    create_table :accreditations do |t|

      t.string :institution_name
      t.string :ope
      t.string :institution_ipeds_unitid
      t.string :campus_name
      t.string :campus_ipeds_unitid
      t.string :csv_accreditation_type
      t.string :agency_name, null: false
      t.string :last_action
      t.string :periods

      t.timestamps null: false

      t.index :institution_name
      t.index :institution_ipeds_unitid
      t.index :campus_name
      t.index :campus_ipeds_unitid
    end
  end
end
