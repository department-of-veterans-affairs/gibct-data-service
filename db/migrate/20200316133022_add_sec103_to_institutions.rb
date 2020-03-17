class AddSec103ToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :complies_with_sec_103, :boolean
    add_column :institutions, :solely_requires_coe, :boolean
    add_column :institutions, :requires_coe_and_criteria, :boolean
    add_column :institutions_archives, :complies_with_sec_103, :boolean
    add_column :institutions_archives, :solely_requires_coe, :boolean
    add_column :institutions_archives, :requires_coe_and_criteria, :boolean
  end
end