class AddCampusTypeColumns < ActiveRecord::Migration
  def up
    add_column :weams, :campus_type, :string
    add_column :weams, :parent_facility_code_id, :string
  end

  def down
    remove_column :weams, :campus_type
    remove_column :weams, :parent_facility_code_id
  end 
end