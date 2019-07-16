class AddPreferredProviderColumnToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :preferred_provider, :boolean, default: false
  end
end