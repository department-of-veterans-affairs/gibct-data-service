class CreateAccreditationInstituteCampus < ActiveRecord::Migration
  def change
    create_table :accreditation_institute_campuses do |t|
      t.integer :dapip_id
      t.string :ope
      t.string :location_name
      t.string :parent_name
      t.integer :parent_dapip_id
      t.string :location_type
      t.string :address
      t.string :general_phone
      t.string :admin_name
      t.string :admin_phone
      t.string :admin_email
      t.string :fax
      t.date :update_date

      t.timestamps null: false
    end
  end
end
