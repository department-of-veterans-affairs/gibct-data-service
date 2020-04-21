class AddIndexToHcms < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :hcms, :ope6, algorithm: :concurrently
  end
end
