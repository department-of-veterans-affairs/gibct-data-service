class AddCountryIndexToInstitutions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :institutions, :country, algorithm: :concurrently
  end
end
