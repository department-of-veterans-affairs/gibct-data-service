class CreateHcms < ActiveRecord::Migration
  def change
    create_table :hcms do |t|
      t.string :ope, null: false
      t.string :ope6, null: false
      t.string :institution
      t.string :hcm_type, null: false
      t.string :hcm_reason, null: false

      t.timestamps null: false

      t.index :ope 
      t.index :institution
    end
  end
end
