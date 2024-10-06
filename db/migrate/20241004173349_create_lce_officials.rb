class CreateLceOfficials < ActiveRecord::Migration[7.1]
  def change
    create_table :lce_officials do |t|
      t.string :name
      t.string :title
      t.references :institution, foreign_key: true

      t.timestamps
    end
  end
end
