class AddSchoolsEmployersToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :employer_provider, :boolean
    add_column :institutions, :school_provider, :boolean
  end
end
