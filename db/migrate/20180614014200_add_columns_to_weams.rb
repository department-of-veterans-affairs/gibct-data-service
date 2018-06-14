class AddColumnsToWeams < ActiveRecord::Migration
  def change
    # Note this is going to result in null values, three-state-boolean problem
    add_column :weams, :priority_enrollment, :boolean
    add_column :weams, :online_only, :boolean
    add_column :weams, :independent_study, :boolean
    add_column :weams, :distance_learning, :boolean
  end
end
