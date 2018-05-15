class AddColumnsToInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :f1sysnam, :string
    add_column :institutions, :f1syscod, :integer
    add_column :institutions, :ialias, :string
  end
end
