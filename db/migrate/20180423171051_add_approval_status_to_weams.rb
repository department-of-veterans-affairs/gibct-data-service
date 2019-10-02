class AddApprovalStatusToWeams < ActiveRecord::Migration[4.2]
  def change
    add_column :weams, :approval_status, :string
  end
end
