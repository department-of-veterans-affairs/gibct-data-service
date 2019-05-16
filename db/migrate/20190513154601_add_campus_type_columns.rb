class AddCampusTypeColumns < ActiveRecord::Migration
    def change
      %w[
        campus_type
        parent_facility_code_id
      ].each do |attr|
        type = :string
        add_column(:weams, attr, type)
      end
    end   
  end