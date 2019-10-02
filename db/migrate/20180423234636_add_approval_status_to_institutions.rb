class AddApprovalStatusToInstitutions < ActiveRecord::Migration[4.2]
  def change
    add_column :institutions, :approval_status, :string
  end
end
