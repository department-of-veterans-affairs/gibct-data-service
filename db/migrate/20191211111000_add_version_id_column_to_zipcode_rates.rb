class AddVersionIdColumnToZipcodeRates < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :zipcode_rates, :version, foreign_key: true, index: false
    add_index :zipcode_rates, :version_id, algorithm: :concurrently
  end
end
