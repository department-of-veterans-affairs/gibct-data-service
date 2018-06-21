class AddSchoolClosuresDefault < ActiveRecord::Migration
  def change
    change_column_default :institutions, :school_closing, false
  end
end
