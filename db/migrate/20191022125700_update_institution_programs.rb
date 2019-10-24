class UpdateInstitutionPrograms < ActiveRecord::Migration[5.2]
  def change
    change_column_null :institution_programs, :facility_code, true
  end
end
