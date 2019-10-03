class AddNewWeamsIndexes < ActiveRecord::Migration[4.2]
  disable_ddl_transaction!

  def change
    add_index(:institutions, :online_only, algorithm: :concurrently)
    add_index(:institutions, :distance_learning, algorithm: :concurrently)
  end
end
