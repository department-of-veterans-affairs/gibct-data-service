class AddSchoolClosuresDefault < ActiveRecord::Migration[4.2]
  def change
    change_column_default :institutions, :school_closing, false
  end
end
