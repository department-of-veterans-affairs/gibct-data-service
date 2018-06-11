class AddApprovalStatusToWeams < ActiveRecord::Migration
  def change
    add_column :weams, :approval_status, :string
  end
end
