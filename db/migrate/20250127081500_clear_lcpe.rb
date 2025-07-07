class ClearLcpe < ActiveRecord::Migration[7.1]
  def change
    # Removing development tables that were shared on a branch, and may have made it out to prod on accident.
    drop_table :lce_exams if table_exists?(:lce_exams)
    drop_table :lce_institutions if table_exists?(:lce_institutions)
    drop_table :lce_license_and_certs if table_exists?(:lce_license_and_certs)
    drop_table :lce_officials if table_exists?(:lce_officials)
    drop_table :license_certification_institutions if table_exists?(:license_certification_institutions)

    # Resetting to pristine state before creating LCPE tables in subsequent migrations.
    drop_table :lcpe_feed_lacs if table_exists?(:lcpe_feed_lacs)
    drop_table :lcpe_lacs if table_exists?(:lcpe_lacs)
    drop_table :lcpe_lac_tests if table_exists?(:lcpe_lac_tests)
    drop_table :lcpe_feed_nexams if table_exists?(:lcpe_feed_nexams)
    drop_table :lcpe_exams if table_exists?(:lcpe_exams)
    drop_table :lcpe_exam_tests if table_exists?(:lcpe_exam_tests)
  end
end
