class AddInStateTuitionUrl < ActiveRecord::Migration[6.0]
  def change
    add_column :weams, :in_state_tuition_url, :string
    add_column :institutions, :in_state_tuition_url, :string
    add_column :institutions_archives, :in_state_tuition_url, :string
  end
end
