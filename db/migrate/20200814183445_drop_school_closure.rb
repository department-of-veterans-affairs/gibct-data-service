class DropSchoolClosure < ActiveRecord::Migration[5.2]
  def change
    drop_table :school_closures, if_exists: true
  end
end
