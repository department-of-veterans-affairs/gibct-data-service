class CreateCalculatorConstantVersions < ActiveRecord::Migration[7.1]
  def change
    create_table :calculator_constant_versions do |t|
      t.references :version, foreign_key: true
      t.string :name
      t.float :float_value
      t.string :description

      t.timestamps
    end

    add_index :calculator_constant_versions, "name", name: "idx_calc_constant_vsns_nm"
  end
end
