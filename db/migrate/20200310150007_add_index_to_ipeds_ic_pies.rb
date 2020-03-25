class AddIndexToIpedsIcPies < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :ipeds_ic_pies, :cross, algorithm: :concurrently
  end
end
