class AddVersionIdColumnToZipcodeRatesArchives < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :zipcode_rates_archives, :version, foreign_key: true, index: false
    add_index :zipcode_rates_archives, :version_id, algorithm: :concurrently
  end
end