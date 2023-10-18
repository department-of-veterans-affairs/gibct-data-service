class CreateSection1015s < ActiveRecord::Migration[6.1]
  def change
    create_table :section1015s do |t|
      t.string :facility_code, null: false
      t.string :institution
      t.date :effective_date
      t.integer :active_students
      t.date :last_graduate
      t.string :celo
      t.string :weams_withdrawal_processed

      t.timestamps
    end

    add_index :section1015s, :celo
    add_index :section1015s, :facility_code
  end
end
