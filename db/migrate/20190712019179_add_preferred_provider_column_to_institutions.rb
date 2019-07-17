class AddPreferredProviderColumnToInstitutions < ActiveRecord::Migration
  def up
    safety_assured do
        change_table(:institutions, bulk: true) do |t|
        t.column :preferred_provider, :boolean 

        t.change_default :preferred_provider, false
      end
    end
  end

  def down
    remove_column :institutions, :preferred_provider
  end
end