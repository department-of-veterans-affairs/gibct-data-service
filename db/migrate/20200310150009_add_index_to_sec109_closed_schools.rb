class AddIndexToSec109ClosedSchools < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  def change
    add_index :sec109_closed_schools, :facility_code, algorithm: :concurrently
  end
end
