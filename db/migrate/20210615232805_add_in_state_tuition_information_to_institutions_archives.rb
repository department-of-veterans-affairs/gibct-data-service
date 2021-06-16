class AddInStateTuitionInformationToInstitutionsArchives < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions_archives, :in_state_tuition_information, :string
  end
end
