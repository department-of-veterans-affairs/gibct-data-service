class CreateCostOfLivingAdjustment < ActiveRecord::Migration[7.1]
  def change
    create_table :cost_of_living_adjustments do |t|
      t.string :benefit_type, null: false
      t.decimal :rate, precision: 5, scale: 2, null: false

      t.timestamps
    end

    add_index :cost_of_living_adjustments, :benefit_type, unique: true
  end
end
