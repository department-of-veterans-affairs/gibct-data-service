class AddInstitutionsLongLatIndex < ActiveRecord::Migration[6.0]
  disable_ddl_transaction!
  def change
    add_index :institutions, [:latitude, :longitude], algorithm: :concurrently
  end
end
