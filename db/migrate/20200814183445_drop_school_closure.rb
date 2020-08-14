class DropSchoolClosure < ActiveRecord::Migration[5.2]
  def change
    if table_exists?("school_closures")
      drop_table :school_closures
    end
  end
end
