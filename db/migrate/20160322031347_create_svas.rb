class CreateSvas < ActiveRecord::Migration
  def change
    create_table :svas do |t|
      t.string :institution
      t.string :cross
      t.string :student_veteran_link

      t.timestamps null: false

      t.index :institution
      t.index :cross
    end
  end
end
