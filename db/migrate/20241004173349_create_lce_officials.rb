class CreateLceOfficials < ActiveRecord::Migration[7.1]
  def change
    create_table :lce_officials do |t|
      t.string :name
      t.string :title
      t.integer :institution_id

      t.timestamps
    end
  end
end
