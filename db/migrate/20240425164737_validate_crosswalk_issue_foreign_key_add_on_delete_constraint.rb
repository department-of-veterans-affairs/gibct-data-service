class ValidateCrosswalkIssueForeignKeyAddOnDeleteConstraint < ActiveRecord::Migration[7.0]
  def change
    validate_foreign_key :crosswalk_issues, :ipeds_hds
  end
end
