class AddColumnsToZipcodeRates < ActiveRecord::Migration[4.2]
  def change
    add_column :zipcode_rates, :version, :integer

    add_index :zipcode_rates, [:version, :zip_code] , using: :btree
  end
end
