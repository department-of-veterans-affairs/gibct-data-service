class DropSchoolCertifyingOfficialsArchives < ActiveRecord::Migration[5.2]
  def change
    drop_table :school_certifying_officials_archives
  end
end
