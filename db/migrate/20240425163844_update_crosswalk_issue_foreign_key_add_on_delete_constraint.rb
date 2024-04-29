class UpdateCrosswalkIssueForeignKeyAddOnDeleteConstraint < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :crosswalk_issues, column: :ipeds_hd_id
    add_foreign_key :crosswalk_issues, :ipeds_hds, column: :ipeds_hd_id, on_delete: :cascade, validate: false
  end
end
