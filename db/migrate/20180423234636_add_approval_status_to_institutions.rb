class AddApprovalStatusToInstitutions < ActiveRecord::Migration
  def change
    add_column :institutions, :approval_status, :string
  end
end
