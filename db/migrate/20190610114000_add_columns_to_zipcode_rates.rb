class AddColumnsToZipcodeRates < ActiveRecord::Migration
  def change
    add_column :zipcode_rates, :dod_mha_rate, :float
    add_column :zipcode_rates, :version, :integer
  end
end
