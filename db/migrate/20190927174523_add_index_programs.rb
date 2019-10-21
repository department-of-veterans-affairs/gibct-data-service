class AddIndexPrograms < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :programs, [:facility_code, :description], algorithm: :concurrently
  end
end
