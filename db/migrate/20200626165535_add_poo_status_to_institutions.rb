class AddPooStatusToInstitutions < ActiveRecord::Migration[5.2]
  def change
    add_column :institutions, :poo_status, :string
    add_column :institutions_archives, :poo_status, :string
  end
end
