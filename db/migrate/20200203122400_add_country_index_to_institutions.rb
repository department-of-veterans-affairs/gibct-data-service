class AddCountryIndexToInstitutions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def up
    add_index :institutions, :country, algorithm: :concurrently
  end

  def down
    remove_index :institutions, :country
  end
end
