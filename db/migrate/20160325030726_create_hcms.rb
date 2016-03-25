class CreateHcms < ActiveRecord::Migration
  def change
    create_table :hcms do |t|
      t.string :ope, null: false
      t.string :institution, null: false
      t.string :city
      t.string :state
      t.string :monitor_method, null: false
      t.string :reason, null: false

      t.timestamps null: false

      t.index :ope 
      t.index :institution
    end
  end
end
