class RemoveInstitutionsAddressIndexes < ActiveRecord::Migration[5.2]

  def change
    safety_assured do
      execute "DROP INDEX IF EXISTS index_institutions_institution_lprefix;"
    end

    remove_index :institutions, :institution
    remove_index :institutions, :city
    remove_index :institutions, :address_1
    remove_index :institutions, :address_2
    remove_index :institutions, :address_3
  end

end
