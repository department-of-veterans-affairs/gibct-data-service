class AddOpeAndCrossIndexesToWeams < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_index :weams, :ope, algorithm: :concurrently
    add_index :weams, :cross, algorithm: :concurrently
  end
end
