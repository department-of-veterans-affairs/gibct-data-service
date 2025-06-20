class CreateCalculatorConstantVersionsArchives < ActiveRecord::Migration[7.1]
  def change
    create_table :calculator_constant_versions_archives do |t|
      t.bigint :version_id
      t.string :name
      t.float :float_value
      t.string :description

      t.timestamps
    end
  end
end
