class CreateSvas < ActiveRecord::Migration
  def change
    create_table :svas do |t|
      t.string :institution, null: false  
      t.string :cross
      t.string :city  
      t.string :state 
      t.string :student_veteran_link

      t.timestamps null: false

      t.index :institution
      t.index :cross
    end
  end
end
