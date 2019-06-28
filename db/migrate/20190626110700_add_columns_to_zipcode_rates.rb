class AddColumnsToZipcodeRates < ActiveRecord::Migration
  def change
    add_column :zipcode_rates, :version, :integer

    add_index :zipcode_rates, [:zip_code, :version] , using: :btree
  end
end
