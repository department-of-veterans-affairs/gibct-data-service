class AddVrrapToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :vrrap, :boolean, default: false
    add_column :institutions_archives, :vrrap, :boolean
  end
end
