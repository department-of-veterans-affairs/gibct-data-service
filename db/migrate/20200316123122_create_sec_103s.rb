class CreateSec103s < ActiveRecord::Migration[5.2]
  def change
    create_table :sec_103s do |t|
      t.string "name"
      t.string "facility_code", null: false
      t.boolean "complies_with_sec_103"
      t.boolean "solely_requires_coe"
      t.boolean "requires_coe_and_criteria"
    end
  end
end
