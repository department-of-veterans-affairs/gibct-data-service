class AddIndexToCalculatorConstantVersionsArchives < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :calculator_constant_versions_archives, :version_id, algorithm: :concurrently
  end
end
