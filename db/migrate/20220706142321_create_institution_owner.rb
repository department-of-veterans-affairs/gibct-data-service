class CreateInstitutionOwner < ActiveRecord::Migration[6.1]
  def change
    create_table :institution_owners do |t|
      t.string :facility_code
      t.string :institution_name
      t.string :chief_officer
      t.string :ownership_name
      t.timestamps
    end
  end
end
