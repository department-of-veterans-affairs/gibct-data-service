class AddCampusTypeColumns < ActiveRecord::Migration
  def change
    add_column :weams, :campus_type, :string
    add_column :weams, :parent_facility_code_id, :string
    add_column :institutions, :campus_type, :string
    add_column :institutions, :parent_facility_code_id, :string
    add_column :institutions_archives, :campus_type, :string
    add_column :institutions_archives, :parent_facility_code_id, :string
  end   
end
