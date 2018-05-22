class CreateZipcodeRates < ActiveRecord::Migration
  def change
    create_table :zipcode_rates do |t|
      t.string :zip_code
      t.string :mha_code
      t.string :string
      t.string :mha_name
      t.string :mha_rate
      t.string :mha_rate_grandfathered

      t.timestamps null: false
    end
  end
end
