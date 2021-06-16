class AddInStateTuitionInformationToInstitutions < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :in_state_tuition_information, :string
    add_column :institutions_archives, :in_state_tuition_information, :string
  end
end
