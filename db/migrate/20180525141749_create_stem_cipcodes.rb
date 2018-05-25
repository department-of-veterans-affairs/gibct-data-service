class CreateStemCipcodes < ActiveRecord::Migration
  def change
    create_table :stem_cipcodes do |t|
    	t.integer :two_digit_series
      t.string :twentyten_cip_code
      t.string :cip_code_title

      t.timestamps null: false
    end
  end
end
