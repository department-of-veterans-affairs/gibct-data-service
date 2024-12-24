class CreateLcpeFeedLacs < ActiveRecord::Migration[7.1]
  def change
    create_table :lcpe_feed_lacs do |t|
      t.string :facility_code
      t.string :edu_lac_type_nm
      t.string :lac_nm
      t.string :test_nm
      t.string :fee_amt

      t.timestamps
    end

    add_index :lcpe_feed_lacs, :facility_code
    add_index :lcpe_feed_lacs, :lac_nm
    
    create_table :lcpe_lacs do |t|
      t.string :facility_code
      t.string :edu_lac_type_nm
      t.string :lac_nm
    end

    create_table :lcpe_lac_tests do |t|
      t.integer :lac_id
      t.string :test_nm
      t.string :fee_amt
    end
  end
end
