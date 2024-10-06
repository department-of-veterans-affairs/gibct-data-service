class CreateLceExams < ActiveRecord::Migration[7.1]
  def change
    create_table :lce_exams do |t|
      t.string :name
      t.text :description
      t.date :dates
      t.decimal :amount
      t.references :institution, foreign_key: true

      t.timestamps
    end
  end
end
