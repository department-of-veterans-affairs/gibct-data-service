class CreatePost911Stats < ActiveRecord::Migration[5.2]
  def change
    create_table :post911_stats do |t|
      t.string :facility_code, null: false
      t.integer :tuition_and_fee_count
      t.integer :tuition_and_fee_payments
      t.float :tuition_and_fee_total_amount
      t.integer :yellow_ribbon_count
      t.integer :yellow_ribbon_payments
      t.integer :yellow_ribbon_total_amount
      t.index :facility_code
    end
  end
end