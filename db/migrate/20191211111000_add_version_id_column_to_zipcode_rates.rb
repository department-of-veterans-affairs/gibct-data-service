class AddVersionIdColumnToZipcodeRates < ActiveRecord::Migration[5.1]
  def change
    add_column :zipcode_rates, :version_id, :integer
  end
end
