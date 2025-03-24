class CreateLcpeFeedNexams < ActiveRecord::Migration[7.1]
  def change
    create_table :lcpe_feed_nexams do |t|
      t.string :facility_code
      t.string :nexam_nm
      t.string :descp_txt
      t.string :fee_amt
      t.string :begin_dt
      t.string :end_dt

      t.timestamps
    end

    add_index :lcpe_feed_nexams, :facility_code
    add_index :lcpe_feed_nexams, :nexam_nm

    create_table :lcpe_exams do |t|
      t.string :facility_code
      t.string :nexam_nm
    end

    create_table :lcpe_exam_tests do |t|
      t.integer :exam_id
      t.string :descp_txt
      t.string :fee_amt
      t.string :begin_dt
      t.string :end_dt
    end
  end
end
