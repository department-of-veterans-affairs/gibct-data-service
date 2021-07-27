class AddInStateTuitionInformationToWeams < ActiveRecord::Migration[6.0]
  def change
    add_column :weams, :in_state_tuition_information, :string
  end
end
