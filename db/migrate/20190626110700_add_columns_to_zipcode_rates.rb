class AddColumnsToZipcodeRates < ActiveRecord::Migration
  def change
    add_column :zipcode_rates, :version, :integer

    add_index :zipcode_rates, [:version, :zip_code] , using: :btree
  end
end
