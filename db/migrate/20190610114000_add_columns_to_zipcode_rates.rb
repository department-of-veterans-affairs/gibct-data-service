class AddColumnsToZipcodeRates < ActiveRecord::Migration
  def change
    add_column :zipcode_rates, :dod_mha_rate, :float
    add_column :zipcode_rates, :version, :integer

    add_index :zipcode_rates, :zip_code, name: "index_zipcode_rates_on_zip_code", using: :btree
    add_index :zipcode_rates, :version, name: "index_zipcode_rates_on_version", using: :btree
  end
end
