class AddColumnsToInstitutions < ActiveRecord::Migration[4.2]
  def change
    # Note this is going to result in null values, three-state-boolean problem
    add_column :institutions, :priority_enrollment, :boolean
    add_column :institutions, :online_only, :boolean
    add_column :institutions, :independent_study, :boolean
    add_column :institutions, :distance_learning, :boolean
  end
end
