class AddInstitutionAndOpeIndexesToIpedsHds < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :ipeds_hds, :institution, algorithm: :concurrently
    add_index :ipeds_hds, :ope, algorithm: :concurrently
  end
end
