class CreateRateAdjustment < ActiveRecord::Migration[7.1]
  def change
    create_table :rate_adjustments do |t|
      t.integer :benefit_type, null: false
      t.decimal :rate, precision: 5, scale:2, null: false

      t.timestamps
    end

    add_index :rate_adjustments, :benefit_type, unique: true
  end
end
