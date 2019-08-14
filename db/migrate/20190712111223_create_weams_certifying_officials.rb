class CreateWeamsCertifyingOfficials < ActiveRecord::Migration
    def change
      create_table :weams_certifying_officials do |t|
        t.string :facility_code
        t.string :institution_name
        t.string :priority
        t.string :first_name
        t.string :last_name
        t.string :title
        t.string :phone_area_code
        t.string :phone_number
        t.string :phone_extension
        t.string :email
      end
    end
  end